resource "aws_iam_role" "ec2_basic_role" {
  name = "ec2-basic-role-${random_string.bucket_suffix.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_read" {
  role       = aws_iam_role.ec2_basic_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-basic-profile-${random_string.bucket_suffix.result}"
  role = aws_iam_role.ec2_basic_role.name
}

resource "aws_iam_role" "kms_reader_role" {
  name = "kmsReaderRole-${random_string.bucket_suffix.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = aws_iam_role.ec2_basic_role.arn }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "kms_decrypt_policy" {
  name        = "KMSDecryptOnly-${random_string.bucket_suffix.result}"
  description = "Allows KMS decryption"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "kms:Decrypt"
      Resource = aws_kms_key.escalator_key.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "kms_decrypt" {
  role       = aws_iam_role.kms_reader_role.name
  policy_arn = aws_iam_policy.kms_decrypt_policy.arn
}

resource "aws_iam_user" "attacker" {
  name = "attacker-user-${random_string.bucket_suffix.result}"
}

resource "aws_iam_user_policy" "attacker_policy" {
  name = "sqs-escalator-attacker-policy-${random_string.bucket_suffix.result}"
  user = aws_iam_user.attacker.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SQSAccess"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:GetQueueAttributes",
          "sqs:DeleteMessage"
        ]
        Resource = aws_sqs_queue.escalator_queue.arn
      },
      {
        Sid    = "S3PEMRead"
        Effect = "Allow"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.escalator_bucket.arn}/keys/*"
      }
    ]
  })
}

resource "aws_iam_access_key" "attacker_key" {
  user = aws_iam_user.attacker.name
}
    