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
  default     = "10.0.2.0/24"
}



variable "scenario-name" {
  description = "Name of the scenario."
  type        = string
  default     = "cloud-secret-exfil" 
}

#Stack Name
variable "stack-name" {
  description = "Name of the stack."
  default     = "Kcloudlab-cloud-secret-exfil"
  type        = string
}

