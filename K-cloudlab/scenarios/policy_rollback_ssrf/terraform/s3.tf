// s3.tf
resource "aws_s3_bucket" "flag_bucket" {
  bucket        = "policy-rollback-rce-sensitive-data"
  force_destroy = true
}

resource "aws_s3_bucket_object" "flag" {
  bucket  = aws_s3_bucket.flag_bucket.id
  key     = "flag.txt"
  content = "FLAG{pO1iCy_rollb4CK_rcE_5uCCeS5}"
}

// outputs.tf
output "ec2_public_ip" {
  value       = aws_instance.rce_server.public_ip
  description = "공격자가 RCE를 유도할 EC2의 퍼블릭 IP 주소"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.flag_bucket.bucket
  description = "플래그를 저장한 S3 버킷 이름"
}
