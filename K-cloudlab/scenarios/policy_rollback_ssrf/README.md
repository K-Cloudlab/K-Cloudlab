# Scenario: [policy_rollback_ssrf]
===
**Size:** Small/Medium/Large

**Difficulty:** Easy/Moderate/Hard

**Command:** `./cloudgoat.py create policy_rollback_ssrf`

## Scenario Resources
===
- 1 VPC
- 1 EC2
- 1 S3
- 1 IAM Role (인스턴스에 부착된 역할, 정책 버전 존재)

## Scenario Start(s)
===
1. SSRF가 가능한 웹 애플리케이션이 포함된 EC2 인스턴스의 공개 IP 주소 제공


## Scenario Goal(s)
===
S3 버킷의 민감 데이터를 탈취한다

## Summary
===
SSRF 취약점을 가진 EC2 인스턴스를 통해 메타데이터 서비스에 접근하고,
얻은 임시 자격증명으로 IAM 정책을 롤백하여 S3에서 플래그를 획득한다.


## Exploitation Route
===
A flowchart illustrating the routes the attacker may take when completing the scenario. Lucidchart is recommended.

![Scenario Route(s)](https://rhinosecuritylabs.com/wp-content/uploads/2018/07/cloudgoat-e1533043938802-1140x400.jpg)

## Walkthrough - [SERVICE] Secrets
===
Include a high level overview of the attack path here. 

1. Start by...
2. ...
3. ...
4. ...
5. ...
6. ...
7. ...
8. ...

A detailed cheat sheet & walkthrough for this route is available [here](./cheat_sheet.md). 
