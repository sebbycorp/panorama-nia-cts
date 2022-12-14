terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.32.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "api-server" {
  count = var.aws_api_count
  ami                    = "ami-0a59f0e26c55590e9"
  instance_type          = "t2.medium"
  subnet_id              = var.aws_subnet
  vpc_security_group_ids = [aws_security_group.awsapisec.id]
  user_data              = base64encode(templatefile("${path.module}/scripts/fakeservice.sh", { 
    consul_server_ip = var.consul_server_ip,
    CONSUL_VERSION = "1.12.2",
    owner = var.owner
  }))

  key_name               = aws_key_pair.demo.key_name
  associate_public_ip_address = true
}

resource "tls_private_key" "demo" {
  algorithm = "RSA"
}

resource "aws_key_pair" "demo" {
  public_key = tls_private_key.demo.public_key_openssh
}

resource "null_resource" "key" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.demo.private_key_pem}\" > ${aws_key_pair.demo.key_name}.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 *.pem"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f *.pem"
  }


}



resource "aws_security_group" "awsapisec" {
  name   = "awsapisec"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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