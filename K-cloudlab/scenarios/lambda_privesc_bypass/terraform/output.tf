output "access_key_for_yejin" {
  description = "yejin's Access Key ID"
  value       = aws_iam_access_key.attacker_key.id
}

output "secret_key_for_yejin" {
  description = "yejin's Secret Access Key"
  value       = nonsensitive(aws_iam_access_key.attacker_key.secret)
}