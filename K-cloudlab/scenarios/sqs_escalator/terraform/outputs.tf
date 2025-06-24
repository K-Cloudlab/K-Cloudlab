output "attacker_access_key" {
  value = aws_iam_access_key.attacker_key.id
}

output "attacker_secret_key" {
  value = nonsensitive(aws_iam_access_key.attacker_key.secret)
}

output "sqs_queue_url" {
  value = aws_sqs_queue.escalator_queue.url
}

output "ec2_public_ip" {
  value = aws_instance.escalator_ec2.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.escalator_bucket.bucket
}
        