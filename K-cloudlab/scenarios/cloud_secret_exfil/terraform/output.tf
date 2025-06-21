output "attacker1 - easy route" {
  description = "설명 (선택)"
  value       = "easy"
}

output "attacker1_access_key" {
  value     = aws_iam_access_key.attacker_user_key_1.id
}

output "attacker1_secret_key" {
  value     = nonsensitive(aws_iam_access_key.attacker_user_key_1.secret)
}

output "attacker2 - hard route" {
  description = "설명 (선택)"
  value       = "hard"
}

output "attacker2(hard route)_access_key" {
  value     = aws_iam_access_key.attacker_user_key_2.id
}

output "attacker2(hard route)_secret_key" {
  value     = nonsensitive(aws_iam_access_key.attacker_user_key_2.secret)
}