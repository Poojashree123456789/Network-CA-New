provider "aws" {
  region = "us-west-2"
}

# Security Group

resource "aws_security_group" "pooja_security_group" {
  name        = "pooja_allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow HTTP from anywhere
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
    protocol    = "-1" // Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

}

variable "key_name" {
  type    = string
  default = "pooja_terraform_key"
}


resource "aws_key_pair" "pooja_terraform_key" {
  key_name   = var.key_name
  public_key = file("id_pooja.pub")
}

# Crreate EC2 Instance
resource "aws_instance" "dbs_server" {
  ami             = "ami-0c5204531f799e0c6" # Amazon Linux 2 AMI
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.pooja_security_group.name]
  key_name        = aws_key_pair.pooja_terraform_key.key_name
  tags = {
    Name = "DBS_Server"
  }

  # CI/CD

  provisioner "local-exec" {
    command = "sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.public_ip},' -u ec2-user --private-key id_pooja apply.yml"
  }

  # MANUAL PUSH


  # provisioner "local-exec" {
  #   command = "sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.public_ip},' -u ec2-user --private-key ~/.ssh/id_pooja apply.yml"
  # }

}

output "instance_public_ip" {
  value = aws_instance.dbs_server.public_ip
}

