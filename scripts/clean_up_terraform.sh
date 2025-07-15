#!/bin/bash

# Set the root directory relative to the current user's home
ROOT_DIR="$HOME/GitHub/Main/ProxMox/Terraform"

echo "🧹 Cleaning Terraform artifacts in: $ROOT_DIR"

# Find ALL Terraform artifacts
# find "$ROOT_DIR" \
#     \( -name ".terraform" \
#     -o -name ".terraform.lock.hcl" \
#     -o -name "terraform.tfstate" \
#     -o -name "terraform.tfstate.backup" \)

# Find and remove Terraform artifacts
find "$ROOT_DIR" \
    \( -name ".terraform" \
    -o -name ".terraform.lock.hcl" \
    -o -name "terraform.tfstate" \
    -o -name "terraform.tfstate.backup" \) \
    -exec rm -rf {} +

echo "✅ Cleanup complete."
