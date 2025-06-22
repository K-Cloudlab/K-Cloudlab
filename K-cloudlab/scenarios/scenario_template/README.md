# 시나리오: [scenario_name]
**크기:** 소/중/대

**난이도:** 쉬움/중간/어려움

**명령어:** `python kcloudlab.py start <scenario_name> --profile <username>`

## 시나리오 리소스
(예시)
- 1 VPC
- 1 IAM 사용자
- 1 EC2 인스턴스
- 1 S3 버킷

## 시나리오 시작
(예시)
1. 하나의 IAM 사용자 자격 증명 정보가 제공된다.
2. ...

## 시나리오 목표
(예시) S3 버킷 내의 FLAG를 획득한다.

## 요약
이 문제에는 2가지 공격 흐름이 존재한다.  
easy route - 탈취한 자격 증명을 이용해 EC2에 접근하여 SSM으로부터 비밀 FLAG를 획득한다.  
hard route - 탈취한 자격 증명을 이용해 람다 트리거를 해제하고 S3의 실행 파일을 변조하여 EC2를 이용하여 S3에 접근, SecretsManager로부터 비밀 플래그를 획득한다.  


## 공격 루트
![Image](https://github.com/user-attachments/assets/b2868f6b-c1e4-46c5-9184-f11a207b024b)


## 세부 공격 흐름
(예시)
1. 문제에서 제공하는 IAM 사용자 자격 증명 정보를 활용하여 새로운 프로파일을 생성한다.
2. ...<br/>

자세한 풀이 방법은 [이곳](./cheat_sheet.md)에서 확인가능하다.  
