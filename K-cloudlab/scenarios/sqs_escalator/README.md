# 시나리오 : [sqs-escalator]

**크기:** 중   
  
**난이도:** 중간

**명령어:** `python kcloudlab.py start sqs_escalator --profile <username>`

## 시나리오 리소스

- EC2 × 1  
- S3 × 1  
- KMS × 1  
- IAM 사용자 × 1  
- IAM 역할 × 2  
- SQS × 1

## 시나리오 시작

제한된 권한만 가진 IAM 사용자가 SQS 메시지를 조회할 수 있는 상태에서 시작합니다.

## 시나리오 목표

KMS로 암호화된 플래그 파일을 복호화하여 획득하세요.

## 요약

공격자는 SQS 메시지를 통해 EC2 접근 정보를 확보하고,  
메타데이터 서비스를 공격으로 EC2 역할 자격 증명을 탈취합니다.  
이후 `AssumeRole`을 통해 KMS 복호화 권한을 얻고,  
암호화된 플래그를 성공적으로 복호화합니다.

## 공격 루트

![attack-path](https://github.com/user-attachments/assets/f7bfee13-b983-4564-a31e-fe4f924b75df)

## 세부 공격 흐름

1. **attacker-user**는 SQS 메시지를 수신하여 EC2 인스턴스 IP, PEM 키 위치, 암호화된 플래그 경로, AssumeRole 힌트를 획득합니다.  
2. S3에서 해당 키 파일을 다운로드한 후, 해당 키를 사용해 EC2 인스턴스에 SSH로 접속합니다.  
3. EC2 내부에서 메타데이터 서비스(`http://169.254.169.254`)를 활용해 EC2에 부착된 IAM 역할의 자격 증명을 탈취합니다.  
4. 탈취한 임시 자격 증명으로 S3에서 암호화된 플래그 파일을 다운로드합니다.  
5. 그러나 해당 역할에는 `kms:decrypt` 권한이 없어 복호화 실패합니다.  
6. SQS 메시지에 포함된 힌트를 바탕으로 `kmsReaderRole`에 대해 `sts:AssumeRole`을 수행해 권한을 상승합니다.  
7. 권한이 상승된 상태에서 KMS 호출을 실행해 암호화를 해제한 플래그를 성공적으로 복호화합니다.
