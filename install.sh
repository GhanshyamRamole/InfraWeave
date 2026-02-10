#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting installation of AWS CLI and Terraform..."

# 1. Update system packages
sudo dnf update -y

# 2. Install AWS CLI v2
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo dnf install unzip -y
unzip -q awscliv2.zip
sudo ./aws/install --update
rm -rf aws awscliv2.zip

# 3. Install Terraform
echo "Installing Terraform..."
sudo dnf install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo dnf install -y terraform

# 4. Verify Installations
echo "---------------------------------------"
echo "Installation Complete!"
aws --version
terraform -version
echo "---------------------------------------"

echo "Next step: Run 'aws configure' to set up your credentials."
