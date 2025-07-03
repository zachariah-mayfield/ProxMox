terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.78.2"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.4"
    }
  }
}

provider "proxmox" {
  endpoint       = "https://${var.proxmox_server_ip}:8006/"
  api_token      = var.proxmox_api_token
  insecure       = true
  ssh {
    agent        = true
    username     = "root"
    private_key = trimspace(file("~/.ssh/id_ed25519"))  # ✅ This should be the **private** key!
  }
}

# RENDER cloud-init YAML from template with variables
locals {
  rendered_user_data = templatefile("${path.module}/templates/user-data.tpl", {
    vm_name             = var.target_vm_name
    cloud_init_user     = var.cloud_init_user
    cloud_init_root     = "root"
    cloud_init_password = bcrypt(var.cloud_init_password)
    cloudinit_ssh_key   = trimspace(file(var.ssh_key_path))
    cloudinit_autologin = true
  })
}

# WRITE the rendered user-data YAML to a local file
resource "local_file" "rendered_user_data" {
  content  = local.rendered_user_data
  filename = "${path.module}/cloudinit/user-data-${var.target_vm_name}.yml"
}

resource "proxmox_virtual_environment_file" "user_data" {
  content_type = "snippets"
  datastore_id = "local"           # use local storage for cloud-init snippets
  node_name    = var.proxmox_node_name

  source_file {
    path = local_file.rendered_user_data.filename
  }

  overwrite = true
}

resource "proxmox_virtual_environment_vm" "clone_vm" {
  name      = var.target_vm_name
  node_name = var.proxmox_node_name
  vm_id     = var.target_vm_id
  on_boot   = false
  started   = true

  clone {
    vm_id     = var.vm_template_id
    full      = true
    node_name = var.proxmox_node_name
  }

  cpu {
    type    = "host"
    sockets = 1
    cores   = 4
    numa    = false
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "nvme_pool"
    interface    = "scsi0"
    size         = 50
    aio          = "io_uring"
    cache        = "none"
    discard      = "ignore"
    backup       = true
    replicate    = true
  }

  network_device {
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot_order = ["scsi0", "ide2"]

  agent {
    enabled = true
  }

  serial_device {
    device = "socket" 
  }

  vga {
    type   = "serial0"
    memory = 16
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    datastore_id      = "local" # ← STAYS "local" to match snippet location
    user_data_file_id = proxmox_virtual_environment_file.user_data.id
  } 
    # user_account {
    #   username = "ubuntu"
    #   password = "ubuntu"
    #   keys     = [trimspace(file("~/.ssh/id_ed25519.pub"))]
    # }

}

output "vm_name" {
  value = proxmox_virtual_environment_vm.clone_vm.name
}

output "vm_id" {
  value = proxmox_virtual_environment_vm.clone_vm.vm_id
}

output "vm_ip" {
  value = proxmox_virtual_environment_vm.clone_vm.ipv4_addresses
}