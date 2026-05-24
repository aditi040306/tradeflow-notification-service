# ============================================================
# TradeFlow Infrastructure
# This file defines WHAT AWS resources we want
# Terraform reads this and creates them automatically
# ============================================================

# Tell Terraform we are using AWS and which region
provider "aws" {
  region = var.aws_region
}

# ============================================================
# KEY PAIR — SSH key to access our EC2 instance
# ============================================================
resource "aws_key_pair" "tradeflow_key" {
  key_name   = "tradeflow-key"
  public_key = file(var.public_key_path)  # reads your local SSH public key
}

# ============================================================
# SECURITY GROUP — Firewall rules for our EC2 instance
# ============================================================
resource "aws_security_group" "tradeflow_sg" {
  name        = "tradeflow-sg"
  description = "Allow SSH and app traffic"

  # Allow SSH from anywhere (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow app traffic on port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ============================================================
# EC2 INSTANCE — The actual server that runs our app
# ============================================================
resource "aws_instance" "tradeflow_ec2" {
  ami                    = var.ami_id           # Amazon Linux 2 image
  instance_type          = "t3.micro"           # Free tier eligible
  key_name               = aws_key_pair.tradeflow_key.key_name
  vpc_security_group_ids = [aws_security_group.tradeflow_sg.id]

  # Script that runs automatically when EC2 first starts
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user
  EOF

  tags = {
    Name    = "tradeflow-notification-server"
    Project = "TradeFlow"
    Env     = "prod"
  }
}


Your EC2 server is live on AWS. Save these — you'll need them:

```
EC2 Public IP:  3.91.198.41
EC2 Public DNS: ec2-3-91-198-41.compute-1.amazonaws.com
```

**What Terraform just did in 14 seconds:**
- Created a Linux server in AWS us-east-1
- Attached your SSH key so you can log in
- Applied firewall rules (ports 22 and 8080 open)
- Auto-installed Docker on boot via `user_data`

In a real company this would take an ops team hours of console clicking. You did it with code in 14 seconds. That's exactly what IaC means.

---

Let's verify you can SSH into your new server:

```bash
ssh -i ~/.ssh/id_rsa ec2-user@3.91.198.41
```

When it asks:
```
Are you sure you want to continue connecting? yes/no
```

Type `yes` and hit Enter. You should land inside the EC2 server. Paste what you see.


Docker is running on your EC2 server. Now let's pull your image from ECR and run it.

First install AWS CLI on the EC2 server so it can talk to ECR:

```bash
sudo yum install -y aws-cli
```

Then configure it with your IAM credentials:

```bash
aws configure
```

Enter the same credentials as before:
```
AWS Access Key ID: <your access key from CSV>
AWS Secret Access Key: <your secret key from CSV>
Default region name: us-east-1
Default output format: json
```

Then login to ECR and pull your image:

```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS \
  --password-stdin 427267592919.dkr.ecr.us-east-1.amazonaws.com
```

Then pull and run your app:

```bash
docker pull 427267592919.dkr.ecr.us-east-1.amazonaws.com/tradeflow-notification:latest

docker run -d \
  -p 8080:8080 \
  --name tradeflow \
  427267592919.dkr.ecr.us-east-1.amazonaws.com/tradeflow-notification:latest
```

Then test it:

```bash
curl http://localhost:8080/actuator/health
```

Paste the output.


This is a common issue. Your Mac is Apple Silicon (M2/M3 — ARM architecture) but EC2 runs on Intel (AMD64). The Docker image you built on your Mac is ARM-only, so EC2 can't run it.

Fix is to rebuild the image for both platforms. **Exit EC2 first:**

```bash
exit
```

Then on your Mac, rebuild the image specifying AMD64 platform:

```bash
cd "/Users/aditiverma/Documents/Aditi Study/Projects/tradeflow/notification-service"

docker buildx create --use --name multiplatform 2>/dev/null || true

docker buildx build \
  --platform linux/amd64 \
  -t 427267592919.dkr.ecr.us-east-1.amazonaws.com/tradeflow-notification:latest \
  --push \
  .
```

This builds AND pushes directly to ECR in one command — AMD64 compatible with EC2.

This also teaches you something important for the interview — **always build for `linux/amd64` in CI pipelines** because production servers are almost always Intel/AMD, not ARM. GitHub Actions runners are also AMD64 by default.

Paste the output when done.


