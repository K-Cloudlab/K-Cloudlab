variable "region" {
  description = "배포할 AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "퍼블릭 서브넷 CIDR 블록"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "EC2에 사용할 AMI ID - ubuntu 18.04"
  type        = string
  default     = "ami-0a313d6098716f372"
}


variable "scenario-name" {
  description = "Name of the scenario."
  type        = string
  default     = "policy_rollback_rce" 
}

#Stack Name
variable "stack-name" {
  description = "Name of the stack."
  default     = "CloudGoat"
  type        = string
}