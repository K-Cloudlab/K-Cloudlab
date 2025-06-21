// iam.tf
//ec2_role
resource "aws_iam_role" "ec2_role" {
  name = "cloud-secret-exfil-ec2-role"

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
  name        = "cloud-secret-exfil-policy"
  description = "role for ec2"
  policy      = file("policies/ec2role.json")
}


resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.vuln_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "cloud-secret-exfil-instance-profile"
  role = aws_iam_role.ec2_role.name
}

//lambda_role
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_s3_policy"
  role = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

// iam user

resource "aws_iam_user" "attacker_user" {
  name = "attacker-user"
}

resource "aws_iam_user_policy" "attacker_user_policy" {
  name = "attacker-user-policy"
  user = aws_iam_user.attacker_user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sts:GetCallerIdentity",
          "iam:ListRoles",
          "iam:ListAttachedUserPolicies",
          "iam:ListUsers"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:GetFunction",
          "lambda:GetPolicy",
          "lambda:ListEventSourceMappings",
          "lambda:UpdateEventSourceMapping",
          "lambda:DeleteEventSourceMapping",
          "lambda:ListFunctions",
          "lambda:AddPermission",
          "lambda:RemovePermission"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketNotification",
          "s3:PutBucketNotification",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_access_key" "attacker_user_key" {
  user = aws_iam_user.attacker_user.name
}

