resource "local_file" "flag" {
  content  = "FLAG{cloud_ownership_gained}"
  filename = "${path.module}/flag.txt"
}

data "aws_kms_ciphertext" "encrypted_flag" {
  key_id    = aws_kms_key.escalator_key.key_id
  plaintext = local_file.flag.content
}
