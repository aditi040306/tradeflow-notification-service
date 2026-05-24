# ============================================================
# Variables — values we can change without touching main.tf
# ============================================================

variable "aws_region" {
  description = "AWS region to deploy to"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID for us-east-1"
  default     = "ami-0c02fb55956c7d316"  # Amazon Linux 2 - us-east-1
}

variable "public_key_path" {
  description = "Path to your local SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}