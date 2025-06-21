// iam.tf

// EC2 Role
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

// EC2 역할에 취약 정책 붙이기
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.vuln_policy.arn
}

// EC2 역할에 SSM 권한 추가 (AmazonSSMManagedInstanceCore)
resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

// EC2 인스턴스 프로파일 생성
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "cloud-secret-exfil-instance-profile"
  role = aws_iam_role.ec2_role.name
}

// Lambda Role
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

// IAM User - attacker-user 생성
resource "aws_iam_user" "attacker_user" {
  name = "attacker-user"
}

// attacker-user 정책 - 기존 권한 + SSM 세션 관련 권한 추가
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
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:StartSession",
          "ssm:DescribeSessions",
          "ssm:GetSession",
          "ssm:TerminateSession"
        ],
        Resource = "*"
      }
    ]
  })
}

// attacker-user 액세스 키 생성
resource "aws_iam_access_key" "attacker_user_key" {
  user = aws_iam_user.attacker_user.name
}
