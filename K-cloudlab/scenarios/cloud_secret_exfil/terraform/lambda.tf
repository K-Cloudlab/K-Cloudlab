resource "aws_lambda_function" "rollback_lambda" {
  function_name = "s3_rollback_lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "rollback_lambda.lambda_handler"
  runtime       = "python3.11"

  filename         = "${path.module}/scripts/rollback_lambda.zip"  # zip파일 직접 준비 필요
  source_code_hash = filebase64sha256("${path.module}/scripts/rollback_lambda.zip")
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rollback_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.kcloudlab_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.kcloudlab_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.rollback_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
