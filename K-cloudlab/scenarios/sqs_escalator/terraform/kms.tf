resource "aws_kms_key" "escalator_key" {
  description             = "Encryption key for sqs-escalator scenario"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "escalator_key_alias" {
  name          = "alias/sgs_escalator_key_${random_string.bucket_suffix.result}"  # 수정된 부분
  target_key_id = aws_kms_key.escalator_key.key_id
}
