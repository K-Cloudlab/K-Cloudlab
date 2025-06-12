// iam.tf


resource "aws_iam_role" "ec2_role" {
  name = "policy-rollback-rce-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "vuln_policy" {
  name        = "policy-rollback-restricted-policy"
  description = "Default version with minimal permissions"
  policy      = file("policies/v1.json")
}


resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.vuln_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "policy-rollback-rce-instance-profile"
  role = aws_iam_role.ec2_role.name
}