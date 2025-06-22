# 시나리오: [cloud_secret_exfil]
**크기:** 대

**난이도:** 어려움

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
  1. 탈취한 자격 증명을 이용하여 새로운 프로파일을 등록한다.<br/>
  2. 해당 프로파일을 이용하여 IAM 사용자의 기본적인 정보 및 권한을 확인한다.<br/>
  3. SSM Session을 시작할 수 있는 권한이 존재하는 것을 확인한다.<br/>
  4. EC2 이름을 확인하고 새로운 Session을 시작하여서 해당 EC2에 접속한다.<br/>
  5. Secrets Manager의 비밀 목록을 확인하여 비밀 FLAG를 탈취한다.

     
  ### Hard Route
  1. 탈취한 자격 증명을 이용하여 새로운 프로파일을 등록한다.
  2. 해당 프로파일을 이용하여 IAM 사용자의 기본적인 정보 및 권한을 확인한다.
  3. Lambda 트리거를 수정할 수 있는 권한 및 S3 버킷 업로드 권한이 있는 것을 확인한다.
  4. S3 버킷 내의 exec.sh 파일을 수정하여도 다시 이전 버전으로 롤백이 진행되는 것을 확인한다.
  5. Lambda 트리거를 수정하여 더 이상 롤백이 이루어지지 않도록 수정한다.
  6. 리버스 쉘 스크립트를 작성하여 exec.sh 파일을 업데이트한다.
  7. 해당 스크립트가 실행되어 EC2에 접속한다.
  8. Secrets Manager의 비밀 목록을 확인하여 비밀 FLAG를 탈취한다.

  <br/>
자세한 풀이 방법은 [이곳][cheat_sheet.md)에서 확인가능하다.  
