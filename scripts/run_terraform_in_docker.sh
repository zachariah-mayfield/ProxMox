#!/bin/bash

set -e

ACTION="$1"
WORKDIR_NAME="$2"

if [[ -z "$ACTION" || -z "$WORKDIR_NAME" ]]; then
  echo "Usage: $0 {plan|apply|destroy} <terraform-subdir>"
  echo "Example: $0 apply bpg_terraform-clone-vm"
  exit 1
fi

# Absolute path to the Terraform working directory
TERRAFORM_WORKDIR="$HOME/GitHub/Main/ProxMox/Terraform/$WORKDIR_NAME"

if [[ ! -d "$TERRAFORM_WORKDIR" ]]; then
  echo "❌ ERROR: Directory '$TERRAFORM_WORKDIR' does not exist."
  exit 1
fi

# Define Docker Compose file path
DOCKER_COMPOSE_FILE="$HOME/GitHub/Main/ProxMox/Docker/Terraform/docker-compose.yml"

echo "DEBUG: TERRAFORM_WORKDIR = '$TERRAFORM_WORKDIR'"

# Docker Compose run command with -chdir
terraform_cmd() {
  docker compose -f "$DOCKER_COMPOSE_FILE" run --rm terraform -chdir="/workspace/$WORKDIR_NAME" "$@"
}

terraform_plan() {
  terraform_cmd init -upgrade
  terraform_cmd plan -out=tfplan
}

terraform_apply() {
  terraform_cmd init -upgrade
  terraform_cmd apply -auto-approve tfplan
  rm -f "$TERRAFORM_WORKDIR/tfplan"
}

terraform_destroy() {
  terraform_cmd init -upgrade
  terraform_cmd destroy -auto-approve
}


case "$ACTION" in
  plan)
    terraform_plan
    ;;
  apply)
    terraform_plan
    terraform_apply
    ;;
  destroy)
    terraform_destroy
    ;;
  *)
    echo "Unknown action: $ACTION"
    exit 1
    ;;
esac

# Example Usage:
# From inside the ~/GitHub/Main/ProxMox/Scripts/ folder:
# chmod +x run_terraform_in_docker.sh

# ./run_terraform_in_docker.sh plan bpg_terraform-clone-vm
# ./run_terraform_in_docker.sh apply bpg_terraform-clone-vm
# ./run_terraform_in_docker.sh destroy bpg_terraform-clone-vm
