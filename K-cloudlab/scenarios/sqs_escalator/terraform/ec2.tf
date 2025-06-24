resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-key-${random_string.bucket_suffix.result}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg-${random_string.bucket_suffix.result}"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "escalator_ec2" {
  ami                    = "ami-0e9bfdb247cc8de84" # Amazon Linux 2
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = aws_key_pair.ec2_key.key_name

  tags = {
    Name = "sqs-escalator-instance"
  }
}
