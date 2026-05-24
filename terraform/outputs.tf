# ============================================================
# Outputs — printed after terraform apply
# These are the values we need to connect to our server
# ============================================================

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.tradeflow_ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.tradeflow_ec2.public_dns
}

output "ecr_login_command" {
  description = "Command to login to ECR from EC2"
  value       = "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 427267592919.dkr.ecr.us-east-1.amazonaws.com"
}