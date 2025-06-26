# Terraform configuration for deploying an Ubuntu VM on Proxmox
# This configuration uses the bpg Proxmox provider to create a VM with specific settings.
# Terraform bpg/proxmox Provider Documentation URL:
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.46.0"
    }
  }
}

provider "proxmox" {
  endpoint   = var.pm_api_url
  api_token  = var.pm_api_token
  insecure   = true
  ssh {
    username     = "root"
    private_key  = file("~/.ssh/id_ed25519")
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name               = "ubuntu-vm"
  node_name          = "corsair700d"
  description        = "Terraform-provisioned VM using bpg/proxmox"
  cpu {
    cores = 4
  }
  memory {
    dedicated = 8192
  }
  scsi_hardware      = "virtio-scsi-pci"
  boot_order         = ["scsi0"]
  started            = true
  agent {
    enabled = false
  }

  disk {
    datastore_id = "nvme_pool"
    interface    = "scsi0"
    file_id      = "local:iso/ubuntu-24.04.1-live-server-amd64.iso"
    size         = 50
  }

  network_device {
    bridge = "vmbr0"
  }

    serial_device {
      device = "socket"
    }
  
  }
