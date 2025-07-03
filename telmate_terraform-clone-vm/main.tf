# Terraform Telmate/Proxmox provider Documentation:
# https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/guides/cloud_init

terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.2-rc01"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.4"
    }
  }
}

provider "proxmox" {
  pm_api_url             = "https://${var.proxmox_server_ip}:8006/api2/json"
  pm_api_token_id        = var.proxmox_api_token_id
  pm_api_token_secret    = var.proxmox_api_token
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "cloud-init" {
  depends_on = [null_resource.upload_user_data]
  # for_each = var.vm_configs

  vmid              = var.target_vm_id # each.value.target_vm_id
  name              = var.target_vm_name # each.value.target_vm_name
  target_node       = var.proxmox_node_name
  ciuser            = var.cloud_init_user
  cipassword        = var.cloud_init_password
  sshkeys           = trimspace(file(var.ssh_key_path))

  clone_id          = var.vm_template_id # each.value.vm_template_id
  full_clone        = true
  bios              = "seabios"
  agent             = 1
  scsihw            = "virtio-scsi-pci"

  os_type           = "cloud-init"
  memory            = 8192 # each.value.memory

  vm_state          = "started"

  cpu {
    type     = "host"
    sockets  = 1
    cores    = 4
  }

  vga {
    type   = "serial0"
    memory = 16
  }
  serial {
    id   = 0
    type = "socket"
  }

  ipconfig0 = "ip=dhcp"

  network {
    id       = 0
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # Regular disk (e.g., 50G root volume)
  # Cloud-init drive on ide2
  disks {
    scsi {
      scsi0 {
        disk {
          size      = "50G"
          storage   = "nvme_pool"
          replicate = true
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "nvme_pool"
        }
      }
    }
  }

  # Boot order
  boot = "order=scsi0;ide2"

  # Cloud-init configuration 
  cicustom = "user=local:snippets/user-data-${var.target_vm_name}.yml"
  
}

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

resource "local_file" "rendered_user_data" {
  content  = local.rendered_user_data
  filename = "${path.module}/cloudinit/user-data-${var.target_vm_name}.yml"
}

resource "null_resource" "upload_user_data" {
  provisioner "local-exec" {
    command = "scp ${local_file.rendered_user_data.filename} root@${var.proxmox_server_ip}:/var/lib/vz/snippets/user-data-${var.target_vm_name}.yml"
  }
}

output "vmid" {
  value = proxmox_vm_qemu.cloud-init.vmid
}

output "target_vm_name" {
  value = proxmox_vm_qemu.cloud-init.name
}

output "ipconfig0" {
  value = proxmox_vm_qemu.cloud-init.ipconfig0
}