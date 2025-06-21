output "attacker_user_access_key" {
  value     = aws_iam_access_key.attacker_user_key.id
  sensitive = true
}

output "attacker_user_secret_key" {
  value     = aws_iam_access_key.attacker_user_key.secret
  sensitive = true
}