#!/bin/bash

# Exit immediately on error
set -e

echo "🧹 Cleaning up previous Terraform state and cache..."
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