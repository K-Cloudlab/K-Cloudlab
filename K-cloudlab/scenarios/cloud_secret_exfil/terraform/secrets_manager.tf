# 1. 랜덤 문자열 16바이트 생성
resource "random_string" "secret_suffix" {
  length  = 16
  upper   = true
  lower   = true
  numric  = true
  special = false
}

# 2. Secrets Manager 시크릿 생성
resource "aws_secretsmanager_secret" "secretFLAG" {
  name        = "secretFLAG-${random_string.secret_suffix.result}"
  description = "The secret FLAG value."
}

# 3. 해당 시크릿의 버전과 값 업로드
resource "aws_secretsmanager_secret_version" "secretFLAG_version" {
  secret_id     = aws_secretsmanager_secret.secretFLAG.id
  secret_string = file("${path.module}/scripts/secrets.json")
}
