# 시나리오: [cloud_secret_exfil]
**크기:** 큼

**난이도:** 상

**명령어:** `python kcloudlab.py start cloud_secret_exfil --profile <username>`

## 시나리오 리소스
- 1 VPC (외부에서 접속이 가능하도록 설정하는 VPC)
- 2 EC2 (하나는 바로 SSM을 통한 접속이 가능한 EC2, 하나는 S3로부터 파일을 가져와 지속적으로 실행하는 EC2)
- 1 S3 (EC2가 받아서 실행할 파일을 저장)
- 1 Lambda (S3의 이벤트를 트리거하는 람다 함수)
- 1 IAM 사용자 (S3에 파일을 업로드할 수 있는 권한과 RDS관련 권한을 가진 IAM 사용자)
- 1 RDS (민감한 자격 증명 정보가 저장되어 있는 데이터베이스)
- 1 SSM (Secrets Manager에 저장되어 있는 비밀 FLAG 값)
- 2 IAM Role (람다 함수를 편집할 수 있는 권한을 가진 역할, SSM에 접근 가능한 EC2의 역할)

## 시나리오 시작
1. 일반 사용자의 자격 증명 정보가 제공된다.


## 시나리오 목표
SecretsManager에서의 비밀 FLAG 값을 탈취한다.

## 요약
사용자는 처음 자신이 가진 권한을 이용해서 S3에 대한 업로드 권한과 RDS 스냅샷 복구 권한이 있다는 것을 알게 된다.  
자산의 권한을 이용하여 RDS로부터 자격 증명을 탈취한다.
이 문제에는 2가지 공격 흐름이 존재한다.  
easy route - 탈취한 자격 증명을 이용해 EC2에 접근하여 SSM으로부터 비밀 FLAG를 획득한다.  
hard route - 탈취한 자격 증명을 이용해 람다 트리거를 해제하고 S3의 실행 파일을 변조하여 EC2를 이용하여 S3에 접근, SSM으로부터 비밀 플래그를 획득한다.  


## 공격 루트
<예시>
![Image](https://github.com/user-attachments/assets/affa3e11-ebbd-49ae-b687-57b00f53f1c7)


## 세부 공격 흐름

2. 한 IAM 사용자의 자격 증명 정보가 제공된다.
2. 해당 사용자는 S3 버킷에 파일을 업로드 할 수 있는 권한과 RDS 스냅샷을 복구할 수 있는 권한을 갖고 있다.
3. RDS 스냅샷을 복구하여 그 안에 저장되어 있는 2개의 임시 자격 증명 정보를 획득한다.
<br/>
  Easy Route  <br/>
  5. 탈취한 자격 증명을 통해 Easy-Route-EC2에 SSM Session Manager를 통해 접근한다.<br/>
  6. 접속한 EC2의 권한을 통해 SSM의 Secrets Manager로부터 비밀 FLAG값을 탈취한다.
  <br/><br/>
  Hard Route  <br/>
  4. S3 버킷의 exec.sh 파일을 변경한다.<br/>
  5. 람다 함수가 트리거되어 변경 사항이 바로 롤백되는 것을 확인한다.<br/>
  6. 탈취한 자격 증명을 통해 람다 함수를 수정하여 트리거를 해제한다.<br/>
  7. 리버스 쉘을 실행시키는 스크립트를 작성한다.<br/>
  8. S3내의 exec.sh파일을 자신이 작성한 공격 스크립트로 덮어쓴다.<br/>
  9. EC2에서 해당 exec.sh파일을 받아 실행하여 연결이 이루어진다.<br/>
  10. 해당 리버스 쉘을 이용하여 SSM의 Secrets Manager에 접근하여 비밀 FLAG를 탈취한다.<br/>

  <br/>
  자세한 풀이 방법은 [이곳](./cheat_sheet.md)에서 확인가능하다.  
