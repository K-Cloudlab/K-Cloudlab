// security_group.tf
resource "aws_security_group" "ssrf_sg" {
  name        = "policy-rollback-rce-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "policy-rollback-rce-sg"
  }
}

// ec2.tf
resource "aws_instance" "ssrf_server" {
  ami                         = var.ami_id
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