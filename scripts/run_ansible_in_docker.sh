#!/bin/bash

set -e

PLAYBOOK_NAME="$1"

if [[ -z "$PLAYBOOK_NAME" ]]; then
  echo "Usage: $0 <playbook.yml>"
  echo "Example: $0 playbook_delete_vms.yml"
  exit 1
fi

# Set paths
ANSIBLE_DIR="$HOME/GitHub/Main/ProxMox/Ansible"
INVENTORY_FILE="$ANSIBLE_DIR/inventory.yml"
DOCKER_COMPOSE_FILE="$HOME/GitHub/Main/ProxMox/Docker/Ansible/docker-compose.yml"

# Validate files
if [[ ! -f "$ANSIBLE_DIR/$PLAYBOOK_NAME" ]]; then
  echo "❌ ERROR: Playbook '$ANSIBLE_DIR/$PLAYBOOK_NAME' does not exist."
  exit 1
fi

if [[ ! -f "$INVENTORY_FILE" ]]; then
  echo "❌ ERROR: Inventory file '$INVENTORY_FILE' not found."
  exit 1
fi

echo "🔧 Running Ansible playbook: $PLAYBOOK_NAME"
echo "📁 Inventory: $INVENTORY_FILE"
echo "🐳 Using Docker Compose file: $DOCKER_COMPOSE_FILE"

run_ansible_playbook() {
  docker compose -f "$DOCKER_COMPOSE_FILE" run --rm ansible \
    ansible-playbook -i "$(basename "$INVENTORY_FILE")" "$(basename "$PLAYBOOK_NAME")"
}

run_ansible_playbook
