#!/bin/bash

# Path to the directory
TARGET_DIR="$HOME/GitHub/Main/ProxMox/Ansible/"

# Change to the target directory
cd "$TARGET_DIR" || {
    echo "Failed to change directory to $TARGET_DIR"
    exit 1
}

# Show current directory
echo "Now in $(pwd)"

# Prompt the user for the playbook name
read -p "Enter the name of the Ansible playbook to run (e.g., site.yml): " PLAYBOOK

# Check if the file exists
if [[ ! -f "$PLAYBOOK" ]]; then
    echo "❌ Playbook '$PLAYBOOK' not found."
    exit 1
fi

# Run the playbook
echo "▶ Running ansible-playbook -i inventory.ini : $PLAYBOOK"
ansible-playbook -i inventory.ini "$PLAYBOOK"
