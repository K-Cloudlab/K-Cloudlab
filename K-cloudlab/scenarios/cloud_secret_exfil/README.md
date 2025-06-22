# 시나리오: [cloud_secret_exfil]
**크기:** 대

**난이도:** 상

**명령어:** `python kcloudlab.py start cloud_secret_exfil --profile <username>`

## 시나리오 리소스
- 1 VPC (외부에서 접속이 가능하도록 설정하는 VPC)
- 1 EC2 (S3로부터 exec.sh을 가져와서 실행하는 EC2)
- 1 S3 (EC2가 받아서 실행할 파일을 저장)
- 1 Lambda (S3의 이벤트를 트리거하는 람다 함수)
- 2 IAM 사용자 (S3에 파일을 업로드할 수 있는 권한과 람다 관련 권한을 갖는 사용자와 SSM Session관련 권한을 갖는 사용자)
- 1 SSM (Secrets Manager에 저장되어 있는 비밀 FLAG 값)
- 2 IAM Role (SSM에 접근 가능한 EC2의 역할)

## 시나리오 시작
1. 일반 사용자의 자격 증명 정보가 제공된다.
2. EC2 서버는 S3에서 1분마다 exec.sh 파일을 가져와서 실행하지만 exec.sh 파일이 변경되면 람다 트리거가 발동되어 이전 상태로 롤백을 진행한다는 정보가 제공된다.

## 시나리오 목표
SecretsManager에서의 비밀 FLAG 값을 탈취한다.

## 요약
이 문제에는 2가지 공격 흐름이 존재한다.  
easy route - 탈취한 자격 증명을 이용해 EC2에 접근하여 SSM으로부터 비밀 FLAG를 획득한다.  
hard route - 탈취한 자격 증명을 이용해 람다 트리거를 해제하고 S3의 실행 파일을 변조하여 EC2를 이용하여 S3에 접근, SecretsManager로부터 비밀 플래그를 획득한다.  


## 공격 루트
![Image](https://github.com/user-attachments/assets/b2868f6b-c1e4-46c5-9184-f11a207b024b)


## 세부 공격 흐름
2개의 IAM 사용자 계정이 제공된다.
<br/>
  ### Easy Route  <br/>
  1. 탈취한 자격 증명을 통해 Easy-Route-EC2에 SSM Session Manager를 통해 접근한다.<br/>
  2. 접속한 EC2의 권한을 통해 SSM의 Secrets Manager로부터 비밀 FLAG값을 탈취한다.

     
  ### Hard Route
  1. S3 버킷의 exec.sh 파일을 변경한다.<br/>
  2. 람다 함수가 트리거되어 변경 사항이 바로 롤백되는 것을 확인한다.<br/>
  3. 탈취한 자격 증명을 통해 람다 함수를 수정하여 트리거를 해제한다.<br/>
  4. 리버스 쉘을 실행시키는 스크립트를 작성한다.<br/>
  5. S3내의 exec.sh파일을 자신이 작성한 공격 스크립트로 덮어쓴다.<br/>
  6. EC2에서 해당 exec.sh파일을 받아 실행하여 연결이 이루어진다.<br/>
  7. 해당 리버스 쉘을 이용하여 SSM의 Secrets Manager에 접근하여 비밀 FLAG를 탈취한다.<br/>

  <br/>
자세한 풀이 방법은 [이곳](./cheat_sheet.md)에서 확인가능하다.  
