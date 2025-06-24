variable "region" {
  default = "ap-northeast-2"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI"
  default     = "ami-025b11b96f918d085"  
}

variable "public_key" {
  description = "SSH public_key"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKWo9XC3m1HlH6iScXcuD2jGyKI/GDCK+fAIoYG1/vTG4zfSDrxGYlYHwzT9shTeM/1moqn5bl2Aou0OS9MkKx+FroSTuirL6eYc8UhClw1z95+fHLtzz9yXHs5ZM2vV7MweM/gDbwYEPEXYM5tNxlkCu3qu40guubIqiMAe4Lqh+ExDEPKErbbcGCBouZlVw33oKmgQd0P12WYi1w8fEEcfc5RzOQ7MigI+GxzBvYc0NOxRWuJoEBg4TPwhE4szeYsGBLHET7TH2G1iluhDKmxyOTrkQihPENWkdLWWAHB3Ebfgaov/HUr1OBFDz1KnFvMTfG6jl9dlEMt1HI8mKJ"
}
