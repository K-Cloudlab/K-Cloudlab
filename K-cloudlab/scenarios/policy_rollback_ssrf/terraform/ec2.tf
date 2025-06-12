// Amazon Linux 2023 AMI 조회
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"] # Amazon Linux 2023
  }
}

// EC2 인스턴스 생성
resource "aws_instance" "ssrf_server" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.main.id
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ssrf_sg.id]

  user_data = file("${path.module}/scripts/user_data.sh")

  tags = {
    Name = "policy-rollback-rce-ec2"
  }
}

