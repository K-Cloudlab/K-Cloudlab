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

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.vuln_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "cloud-secret-exfil-instance-profile"
  role = aws_iam_role.ec2_role.name
}

// Lambda Role (기존과 동일)
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

// attacker-user-1: Lambda 트리거(이벤트 소스 매핑) 수정 권한 사용자
resource "aws_iam_user" "attacker_user_1" {
  name = "attacker-user-1"
}

resource "aws_iam_user_policy" "attacker_user_policy_1" {
  name = "attacker-user-policy-1"
  user = aws_iam_user.attacker_user_1.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      // Lambda 이벤트 소스 매핑 관련 권한 (변경 가능)
      {
        Effect = "Allow",
        Action = [
          "lambda:ListEventSourceMappings",
          "lambda:UpdateEventSourceMapping",
          "lambda:DeleteEventSourceMapping"
        ],
        Resource = "*"
      },
      // Lambda 함수 조회 및 권한 관련 권한
      {
        Effect = "Allow",
        Action = [
          "lambda:GetFunction",
          "lambda:GetPolicy",
          "lambda:ListFunctions",
          "lambda:AddPermission",
          "lambda:RemovePermission"
        ],
        Resource = "*"
      },
      // 기타 필요한 조회 권한 
      {
        Effect = "Allow",
        Action = [
          "sts:GetCallerIdentity",
          "iam:List*",
          "iam:Get*"
        ],
        Resource = "*"
      },
      // S3 객체 쓰기 및 알림 권한 (기존과 동일)
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketNotification",
          "s3:PutBucketNotification",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:List*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "attacker_user_key_1" {
  user = aws_iam_user.attacker_user_1.name
}

// attacker-user-2: EC2 SSM 접속 권한 사용자
resource "aws_iam_user" "attacker_user_2" {
  name = "attacker-user-2"
}

resource "aws_iam_user_policy" "attacker_user_policy_2" {
  name = "attacker-user-policy-2"
  user = aws_iam_user.attacker_user_2.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      // SSM 세션 시작 및 관리 권한
      {
        Effect = "Allow",
        Action = [
          "ssm:StartSession",
          "ssm:DescribeSessions",
          "ssm:GetSession",
          "ssm:TerminateSession"
        ],
        Resource = "*"
      },
      // 기본 조회 권한 (선택적)
      {
        Effect = "Allow",
        Action = [
          "sts:GetCallerIdentity",
          "iam:List*",
          "iam:Get*",
          "ec2:Describe*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "attacker_user_key_2" {
  user = aws_iam_user.attacker_user_2.name
}
