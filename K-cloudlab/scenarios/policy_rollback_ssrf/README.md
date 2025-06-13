# Scenario: [policy_rollback_ssrf]
**Size:** Small/Medium/Large

**Difficulty:** Easy/Moderate/Hard

**Command:** `./cloudgoat.py create policy_rollback_ssrf`

## Scenario Resources
- 1 VPC (외부에서 접속이 가능하도록 설정하는 VPC)
- 1 EC2 (취약점이 존재하는 웹서버가 동작)
- 1 S3 (기밀 데이터를 저장하고 있는 저장소)
- 1 IAM Role (인스턴스에 부착된 역할, 정책 버전 존재)

## Scenario Start(s)
1. SSRF가 가능한 웹 애플리케이션이 포함된 EC2 인스턴스의 공개 IP 주소가 제공된다.


## Scenario Goal(s)
S3 버킷의 기밀 데이터를 탈취한다.

## Summary
SSRF 취약점을 가진 EC2 인스턴스를 통해 메타데이터 서비스에 접근하고,
얻은 임시 자격증명으로 IAM 정책을 롤백하여 S3에서 기밀 데이터를 탈취한다.


## Exploitation Route
A flowchart illustrating the routes the attacker may take when completing the scenario. Lucidchart is recommended.
<예시>
![Scenario Route(s)](https://rhinosecuritylabs.com/wp-content/uploads/2018/07/cloudgoat-e1533043938802-1140x400.jpg)

## Walkthrough - [SERVICE] Secrets

1. SSRF가 가능한 웹 애플리케이션이 포함된 EC2 인스턴스의 공개 IP 주소가 제공된다.
2. 해당 웹서버의 취약점을 파악하고 메타데이터 서비스로 요청을 보낸 결과를 받을 수 있다는 것을 확인한다.
3. 메타데이터 서비스로 요청을 보내 EC2의 역할에 대한 자격 증명을 획득한다.
4. 해당 자격 증명으로 프로파일을 만들어 정책을 조회하여 2가지 버전의 정책이 있다는 것을 확인한다.
5. 현재 정책에서는 S3에 대한 접근 권한이 없지만 정책의 버전을 변경할 수 있는 권한이 있으며 다른 버전에는 S3에 대한 접근 권한이 있음을 확인한다.
6. 다른 현재 정책의 버전을 변경한다.
7. S3에 대한 접근 권한을 획득하여 이에 접근하고 기밀 데이터를 탈취한다.

자세한 풀이 방법은 [이곳](./cheat_sheet.md)에서 확인가능하다.  
