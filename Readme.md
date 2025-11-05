# Network Infrastructure & Web Deployment Project

This project demonstrates automated infrastructure provisioning and application deployment using **Terraform**, **Ansible**, **Docker**, and **AWS**. It deploys a containerized web application ("Wildlife & Greeneries" website) on an AWS EC2 instance with automated configuration management.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Accessing the Application](#accessing-the-application)
- [Components Explained](#components-explained)
- [Cleanup](#cleanup)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This project automates the following workflow:

1. **Infrastructure Provisioning**: Uses Terraform to create AWS resources (EC2 instance, security groups, SSH key pairs)
2. **Configuration Management**: Uses Ansible to configure the EC2 instance with Docker, Docker Compose, and Nginx
3. **Application Deployment**: Deploys a Dockerized website using Docker Compose
4. **Reverse Proxy Setup**: Configures Nginx as a reverse proxy to route traffic from port 80 to the containerized application on port 8080

## 🏗️ Architecture

```
                                    ┌─────────────────────────┐
                                    │   AWS Cloud (us-west-2) │
                                    └────────────┬────────────┘
                                                 │
                                    ┌────────────▼────────────┐
                                    │   Security Group        │
                                    │   - SSH (22)            │
                                    │   - HTTP (80)           │
                                    │   - HTTPS (443)         │
                                    └────────────┬────────────┘
                                                 │
                                    ┌────────────▼────────────┐
                                    │   EC2 Instance          │
                                    │   (t3.micro)            │
                                    │   Amazon Linux 2        │
                                    └────────────┬────────────┘
                                                 │
                    ┌────────────────────────────┼────────────────────────────┐
                    │                            │                            │
         ┌──────────▼──────────┐    ┌───────────▼──────────┐    ┌───────────▼──────────┐
         │   Nginx              │    │   Docker              │    │   Docker Compose     │
         │   (Reverse Proxy)    │◄───┤   Service             │◄───┤   (Container Mgmt)   │
         │   Port 80            │    │                       │    │                      │
         └──────────────────────┘    └───────────────────────┘    └──────────┬───────────┘
                                                                              │
                                                                 ┌────────────▼───────────┐
                                                                 │  Website Container     │
                                                                 │  (Nginx Alpine)        │
                                                                 │  Port 8080:80          │
                                                                 └────────────────────────┘
```

**Traffic Flow**: 
Internet → EC2 Public IP:80 → Nginx Reverse Proxy → Docker Container:8080 → Website

## 🔧 Prerequisites

Before running this project, ensure you have the following installed:

- **Terraform** (v1.0+)
- **Ansible** (v2.9+)
- **AWS CLI** configured with appropriate credentials
- **SSH key pair** (`id_pooja` and `id_pooja.pub`) in the project root
- **AWS Account** with permissions to create EC2 instances, security groups, and key pairs

### AWS Credentials Setup

```bash
# Configure AWS credentials
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and default region (us-west-2)
```

## 📁 Project Structure

```
Network-CA-New-main/
│
├── terraformtest.tf           # Terraform configuration for AWS infrastructure
├── apply.yml                  # Ansible playbook for server configuration
├── id_pooja                   # SSH private key (keep secure!)
├── id_pooja.pub              # SSH public key
├── terraform.tfstate          # Terraform state file (auto-generated)
├── terraform.tfstate.backup  # Terraform state backup (auto-generated)
│
└── mynewwebsite/             # Website application files
    ├── docker-compose.yml    # Docker Compose configuration
    ├── Dockerfile            # Docker image definition
    └── index.html            # Website content (Wildlife & Greeneries)
```

## 🚀 Setup Instructions

### Step 1: Initialize Terraform

```bash
# Navigate to project directory
cd Network-CA-New-main

# Initialize Terraform
terraform init
```

### Step 2: Review Infrastructure Plan

```bash
# Review what resources will be created
terraform plan
```

### Step 3: Apply Terraform Configuration

```bash
# Create AWS infrastructure
terraform apply
```

When prompted, type `yes` to confirm. Terraform will:
1. Create a security group with SSH, HTTP, and HTTPS rules
2. Upload the public SSH key to AWS
3. Launch an EC2 instance (t3.micro with Amazon Linux 2)
4. Automatically trigger Ansible playbook to configure the instance

### Step 4: Wait for Deployment

The deployment process takes approximately **2-3 minutes**:
- 30 seconds: EC2 instance initialization
- 1-2 minutes: Ansible playbook execution (Docker, Nginx, application deployment)

### Step 5: Get Public IP Address

```bash
# Terraform will output the public IP address
terraform output instance_public_ip
```

## 🌐 Accessing the Application

Once deployment is complete:

1. **Open your web browser**
2. **Navigate to**: `http://<EC2_PUBLIC_IP>`
3. You should see the **"Wildlife & Greeneries"** website

Example: `http://54.123.45.67`

### Verify Deployment

```bash
# SSH into the instance
ssh -i id_pooja ec2-user@<EC2_PUBLIC_IP>

# Check if Docker container is running
docker ps

# Check Nginx status
sudo systemctl status nginx

# View logs
docker logs mywebsite
```

## 🔍 Components Explained

### 1. Terraform Configuration (`terraformtest.tf`)

**Resources Created**:
- **AWS Security Group**: Allows inbound traffic on ports 22 (SSH), 80 (HTTP), and 443 (HTTPS)
- **AWS Key Pair**: Uploads SSH public key for secure access
- **AWS EC2 Instance**: t3.micro instance running Amazon Linux 2
- **Local Exec Provisioner**: Automatically runs Ansible playbook after instance creation

### 2. Ansible Playbook (`apply.yml`)

**Tasks Performed**:
1. Installs Python 3.8 on Amazon Linux 2
2. Installs Docker and starts the Docker service
3. Installs Docker Compose (v2.20.0)
4. Adds ec2-user to docker group
5. Installs and configures Nginx as a reverse proxy
6. Copies website files to `/home/ec2-user/webpage/`
7. Runs Docker Compose to build and start the website container

### 3. Docker Setup (`mynewwebsite/`)

**Dockerfile**:
- Uses `nginx:alpine` base image (lightweight)
- Copies `index.html` to Nginx web root
- Exposes port 80

**Docker Compose**:
- Builds the Docker image
- Runs container on port 8080:80
- Sets restart policy to `always` for high availability

### 4. Website (`index.html`)

A responsive, modern single-page website featuring:
- Wildlife and nature conservation theme
- Responsive grid layout
- Beautiful UI with nature-themed color scheme
- Images from Unsplash
- Conservation tips and information

## 🧹 Cleanup

To destroy all AWS resources and avoid charges:

```bash
# Destroy infrastructure
terraform destroy
```

Type `yes` when prompted. This will:
- Terminate the EC2 instance
- Delete the security group
- Remove the SSH key pair from AWS

## 🔒 Security Considerations

### Current Security Issues

⚠️ **The following configurations are NOT production-ready**:

1. **SSH Key Exposure**: The private key (`id_pooja`) is in the repository
   - **Fix**: Store keys securely, use AWS Secrets Manager or SSH agent forwarding

2. **Open SSH Access**: Security group allows SSH from anywhere (`0.0.0.0/0`)
   - **Fix**: Restrict to specific IP addresses or use AWS Systems Manager Session Manager

3. **No HTTPS**: Website runs on HTTP only
   - **Fix**: Configure SSL/TLS certificates using AWS Certificate Manager and Let's Encrypt

4. **Default VPC**: Uses default VPC without network segmentation
   - **Fix**: Create custom VPC with public/private subnets

5. **Root Privileges**: Ansible uses `become: yes` for all tasks
   - **Fix**: Use principle of least privilege

### Recommended Improvements

```hcl
# Example: Restrict SSH access to your IP only
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["YOUR_IP_ADDRESS/32"]  # Replace with your IP
}
```

## 🛠️ Troubleshooting

### Issue: Ansible connection fails

**Solution**: Wait 30-60 seconds for EC2 instance to fully boot, then run:
```bash
terraform apply
```

### Issue: Website not accessible

**Check**:
1. Security group rules are correctly configured
2. Nginx is running: `sudo systemctl status nginx`
3. Docker container is running: `docker ps`
4. Check Nginx logs: `sudo tail -f /var/log/nginx/error.log`

### Issue: Docker permission denied

**Solution**: 
```bash
sudo usermod -aG docker ec2-user
# Log out and log back in
```

### Issue: Port 8080 already in use

**Solution**:
```bash
docker-compose down
docker-compose up -d --build
```

## 📝 Notes

- The EC2 instance uses Amazon Linux 2 AMI (ami-0c5204531f799e0c6) in us-west-2 region
- Instance type: t3.micro (eligible for AWS free tier)
- The website is completely static and runs in a lightweight Nginx Alpine container
- Ansible playbook uses `ansible_python_interpreter: /usr/bin/python3.8` for compatibility

## 👥 Contributors

- Project demonstrates Infrastructure as Code (IaC) best practices
- Built for educational purposes (Network CA assignment)

## 📄 License

This project is for educational purposes. Feel free to modify and use as needed.

---

**Last Updated**: November 2025

