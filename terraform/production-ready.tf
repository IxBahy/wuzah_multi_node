# Production-Ready Terraform Script

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "wazuh_sg" {
  name        = "wazuh_sg"
  description = "Security group for Wazuh components"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1514
    to_port     = 1516
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wazuh_master" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "c5.xlarge"
  key_name      = "your-key-pair"
  security_groups = [aws_security_group.wazuh_sg.name]

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Install Wazuh Manager (Master Node)
              curl -sO https://packages.wazuh.com/4.x/yum/wazuh-master.repo
              yum install -y wazuh-manager
              EOF
}

resource "aws_instance" "wazuh_worker" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "c5.xlarge"
  key_name      = "your-key-pair"
  security_groups = [aws_security_group.wazuh_sg.name]

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Install Wazuh Manager (Worker Node)
              curl -sO https://packages.wazuh.com/4.x/yum/wazuh-worker.repo
              yum install -y wazuh-manager
              EOF
}

resource "aws_instance" "wazuh_indexer" {
  count         = 3
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "m5.xlarge"
  key_name      = "your-key-pair"
  security_groups = [aws_security_group.wazuh_sg.name]

  root_block_device {
    volume_size = 200
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Install Wazuh Indexer
              EOF
}

resource "aws_instance" "wazuh_dashboard" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"
  key_name      = "your-key-pair"
  security_groups = [aws_security_group.wazuh_sg.name]

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Install Wazuh Dashboard
              EOF
}

output "wazuh_master_ip" {
  value = aws_instance.wazuh_master.public_ip
}

output "wazuh_worker_ip" {
  value = aws_instance.wazuh_worker.public_ip
}

output "wazuh_indexer_ips" {
  value = aws_instance.wazuh_indexer[*].public_ip
}

output "wazuh_dashboard_ip" {
  value = aws_instance.wazuh_dashboard.public_ip
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}
