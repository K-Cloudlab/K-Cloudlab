resource "aws_s3_bucket" "flag_bucket" {
  bucket = "flag-bucket-lambda-privesc"
  force_destroy = true
}

resource "aws_s3_bucket_object" "flag_file" {
  bucket  = aws_s3_bucket.flag_bucket.id
  key     = "flag.txt"
  content = "FLAG{happyhappyhappy~!}"
}

resource "aws_s3_bucket_policy" "flag_policy" {
  bucket = aws_s3_bucket.flag_bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "AWS": "${aws_iam_role.lambda_manager.arn}"
    },
    "Action": "s3:GetObject",
    "Resource": "${aws_s3_bucket.flag_bucket.arn}/flag.txt"
  }]
}
EOF
}