resource "aws_s3_bucket" "escalator_bucket" {
  bucket = "sqs-escalator-bucket-${random_string.bucket_suffix.result}"
  force_destroy = true
}

resource "aws_s3_object" "private_key" {
  bucket  = aws_s3_bucket.escalator_bucket.id
  key     = "keys/ec2-access.pem"
  content = tls_private_key.ssh_key.private_key_pem
  content_type = "application/x-pem-file"
}

resource "aws_s3_object" "encrypted_flag" {
  bucket  = aws_s3_bucket.escalator_bucket.id
  key     = "encrypted_flag.bin"
  content = data.aws_kms_ciphertext.encrypted_flag.ciphertext_blob
}
