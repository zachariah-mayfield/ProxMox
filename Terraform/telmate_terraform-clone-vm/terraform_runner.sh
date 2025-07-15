#!/bin/bash

# Exit immediately on error
set -e

TARGET_DIR="$HOME/GitHub/Main/ProxMox/telmate_terraform-clone-vm/" 

# Change to the target directory
cd "$TARGET_DIR" || {
    echo "Failed to change directory to $TARGET_DIR"
    exit 1
}

# Show current directory
echo "Now in $(pwd)"

echo "🧹 Cleaning up previous Terraform state and cache..."
# terraform destroy -auto-approve
rm -rf .terraform/ .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

echo "🔄 Running 'terraform init -upgrade'..."
terraform init -upgrade

echo "📐 Running 'terraform plan'..."
terraform plan

echo "🚀 Applying Terraform plan..."
terraform apply -auto-approve
if [ $? -eq 0 ]; then
    echo "✅ Terraform apply completed successfully."
else
    echo "❌ Terraform apply failed. Please check the output for errors."
    exit 1
fi
echo "🔄 Running 'terraform output' to display outputs..."
terraform output
if [ $? -eq 0 ]; then
    echo "✅ Terraform outputs displayed successfully."
else
    echo "❌ Failed to display Terraform outputs. Please check the output for errors."
    exit 1
fi
# echo "🧹 Cleaning up Terraform state and cache..."
# rm -rf .terraform/ .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
# echo "✅ Terraform operations completed successfully."