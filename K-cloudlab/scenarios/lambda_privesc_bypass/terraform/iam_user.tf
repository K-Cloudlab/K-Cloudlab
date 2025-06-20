resource "aws_iam_user" "attacker" {
  name = "yejin"
}

resource "aws_iam_access_key" "attacker_key" {
  user = aws_iam_user.attacker.name
}


resource "aws_iam_user_policy" "attacker_policy" {
  name = "attacker-policy"
  user = aws_iam_user.attacker.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:*",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}