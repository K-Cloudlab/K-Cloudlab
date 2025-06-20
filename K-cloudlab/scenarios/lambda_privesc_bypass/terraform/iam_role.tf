# DebugRole - Lambda 실행용 역할
resource "aws_iam_role" "debug_role" {
  name = "DebugRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "debug_lambda_basic" {
  role       = aws_iam_role.debug_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "debug_allow_assume" {
  name = "AllowAssume"
  role = aws_iam_role.debug_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "${aws_iam_role.lambda_manager.arn}"
  }]
}
EOF
}

# lambdaManagerRole - 관리자 권한 역할
resource "aws_iam_role" "lambda_manager" {
  name = "lambdaManagerRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "AWS": "${aws_iam_role.debug_role.arn}"
    },
    "Action": "sts:AssumeRole",
    "Condition": {
      "StringEquals": {
        "sts:ExternalId": "poc-external-id"
      }
    }
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_manager_admin" {
  role       = aws_iam_role.lambda_manager.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}