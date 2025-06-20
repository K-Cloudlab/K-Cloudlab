# K-shield Jr 14기 - Terraform을 이용한 시나리오 기반 AWS 침투 테스트 프로젝트
---

## 프로젝트 설명
본 프로젝트는 AWS 침투 테스트 훈련 도구인 CloudGoat을 기반으로, 다양한 보안 시나리오를 실습하고 신규 취약 환경을 직접 구성하여 Terraform을 활용한 인프라 생성 및 클라우드 보안 취약점 분석을 수행하는 프로젝트이다.  
  
실습을 통해 IAM, EC2, S3, Lambda 등 AWS 주요 서비스의 보안 구성 및 오용 사례를 실전처럼 체험하며, 공격자의 관점에서 접근 가능한 경로와 위험 요소를 식별하고 분석하는 것이 목표이다.  
<br/><br/>

## 프로젝트 목표
본 프로젝트의 궁극적인 목표는 CloudGoat 기반의 다양한 침투 테스트 시나리오를 직접 설계 및 구현함으로써, Terraform을 활용한 인프라 자동화 구성 및 AWS 서비스 보안 구성에 대한 심화 이해를 달성하는 것이다.  
  
이를 위해, 의도적으로 보안 설정이 미흡한 클라우드 환경을 구축하고, 실제 공격자의 관점에서 권한 상승, 민감 정보 접근, 서비스 간 위임 관계 악용 등의 침투 테스트를 수행한다. 이러한 과정을 통해 AWS 환경 내 주요 보안 취약점과 공격 벡터를 체계적으로 실습하고 분석하며, 단순한 공격 시뮬레이션을 넘어서 보안 우회 기술 및 대응 전략에 대한 실질적인 경험과 지식을 축적한다.  
  
아울러, 각 시나리오의 구축에는 HashiCorp Terraform을 활용하여 인프라를 코드로 정의하고 재현 가능하도록 구성함으로써, IaC(Infrastructure as Code)에 대한 실전 경험을 강화하고, 복잡한 클라우드 자원 간의 관계 및 정책 구성 방식에 대한 이해도를 높인다.  
  
최종적으로는 침투 테스트 실습을 통해 발견된 보안 취약점에 대한 원인 분석과 함께 실제 보안 강화 방안 및 모범 구성(Best Practices)을 제안하는 데까지 확장함으로써, 공격과 방어 양측 관점에서의 클라우드 보안 역량을 종합적으로 강화하는 것을 목표로 한다.  
<br/><br/>
  
## 환경 구축
- 환경 구축을 수행하고자 하는 PC에서 terraform 설치가 필요하다.
  
  아래 링크에서 terraform 다운로드를 진행하면 된다.  
  (Windows 기준 Windows → AMD64를 다운로드)  
  [테라폼 다운로드 링크](https://developer.hashicorp.com/terraform/install)  
  <br/>  
  
  ![Image](https://github.com/user-attachments/assets/ef684775-b07f-491a-811f-abdf76bf9818)  
  다운로드 하면 위와 같이 terraform.exe와 라이센스 파일이 들어있다.  
  이를 내 PC에서 원하는 위치에 저장하면 된다. (본 예시에서는 C:\Terraform 를 디렉터리로 사용)  
  <br/>  

  ![Image](https://github.com/user-attachments/assets/e5978192-4e7c-4b6c-b9f1-6df151167193)  
  이후 환경 변수 설정에 들어가서 해당 경로를 추가해주면 terraform 설치는 완료된다.  
  <br/>  

- 이후 AWS CLI 설치가 필요하다.
  아래 링크를 통해 ACI 공식 DOC에서 AWS CLI V2를 설치하면 된다.  
  [AWS CLI 설치 링크](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/getting-started-install.html)  
  <br/>

  ![Image](https://github.com/user-attachments/assets/b79821b4-82f3-451d-b91a-ee3faa644cb3)  
  aws --version 명령어를 입력했을 때 정상적으로 버전 정보를 확인할 수 있으면 성공적으로 설치된 것이다.  
<br/>

- AWS CLI 설치가 완료되면 새로운 다양한 리소스를 생성할 수 있도록 관리자 권한이 포함된 IAM 사용자를 생성하여 자격증명 새로운 프로파일로 등록해주어야 한다.  
![Image](https://github.com/user-attachments/assets/a5744f5a-b9ad-4b49-9e64-e348d72a696c)  
<br/>

- 다음으로 본 GitHub의 코드를 전부 받아주면 환경 구축은 완료된다.  
  <br/><br/>
  
## 시나리오 생성
시나리오 생성은 kcloudlab.py가 있는 디렉터리로 들어가서 아래의 명령어를 실행해주면 된다.  
<br/>
  - 시나리오 시작 명령어
    ```bash
    python kcloudlab.py start <scenario_name> --profile kcloudlab
    ```
    <scenario_name>에 원하는 시나리오의 이름을 적어주면 환경 구성이 시작된다.  
    (반드시 관리자 권한이 있는 프로파일을 사용해야 한다)  
<br/>
  - 시나리오 종료 명령어
     ```bash
    python kcloudlab.py finish --profile kcloudlab
    ```
    시나리오 시작과 반대로 종료를 할 때는 시나리오 이름을 적을 필요가 없다.  
    (본 침투 테스트 시뮬레이터에서는 한 번에 하나의 시나리오만 생성 가능하도록 설계되었다)
    


