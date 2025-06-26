# Step 1: Install Vault (Open Source)
# Download Vault
curl -O https://releases.hashicorp.com/vault/1.13.3/vault_1.13.3_linux_amd64.zip

# Unzip
unzip vault_1.13.3_linux_amd64.zip

# Move vault binary to /usr/local/bin
sudo mv vault /usr/local/bin/

# Check installation
vault --version

# For macOS, use Homebrew:
# Bash
# brew install vault

# Step 2: Start Vault in Dev Mode (for testing) 
# This starts Vault unsealed with an in-memory storage backend.
# You’ll see a Root Token printed — save this; you’ll need it to authenticate.
# Bash
# vault server -dev

# Step 3: Export Vault environment variables
# Replace YOUR_ROOT_TOKEN_HERE with the actual root token printed when you started Vault in dev mode.
# In a new terminal (or your Terraform host shell):
# Bash
# export VAULT_ADDR='http://127.0.0.1:8200'
# export VAULT_TOKEN='YOUR_ROOT_TOKEN_HERE'

# Step 4: Store your Proxmox password in Vault
# Replace YOUR_PROXMOX_PASSWORD with your actual Proxmox password.
# This stores your Proxmox password at path secret/proxmox.
# Bash
vault kv put secret/proxmox password="your actual Proxmox password"
