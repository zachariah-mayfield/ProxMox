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
  endpoint       = "https://${var.proxmox_server_ip}:8006/api2/json" # --> may need to remove /api2/json
  api_token      = var.proxmox_api_token
  insecure       = true
  ssh {
    username     = "root"
    private_key  = file("~/.ssh/id_ed25519")
  }
}

# locals {
#   cloud_init_userdata = templatefile("${path.module}/templates/user-data.tpl", {
#     vm_name              = "zm-ubuntu-template"
#     cloud_init_user      = var.cloud_init_user
#     cloud_init_password  = var.cloud_init_password
#     cloudinit_ssh_key    = trimspace(file("~/.ssh/id_ed25519.pub"))
#     cloudinit_autologin  = true
#   })
# }

resource "proxmox_virtual_environment_vm" "vm_template" {
  name        = var.vm_template_name
  node_name   = var.proxmox_node_name
  vm_id       = var.vm_template_id
  template    = true    # replaces this block of code ---> resource "null_resource" "convert_to_template" {***}
  started     = false   # <-- don't start on create
  on_boot     = false
  protection  = false

  bios           = "seabios"
  scsi_hardware  = "virtio-scsi-pci"
  keyboard_layout = "en-us"
  tablet_device  = true

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
    file_id      = "local:iso/jammy-server-cloudimg-amd64.img"
    size         = 50
    interface    = "scsi0"
    datastore_id = var.storage_pool_disk
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

  initialization {
    type         = "nocloud"
    datastore_id = var.storage_pool_cloudinit

    user_account {
      username = var.cloud_init_user
      password = var.cloud_init_password
      keys     = [trimspace(file("~/.ssh/id_ed25519.pub"))]
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    #user_data_file_id = "local:snippets/user-data-${var.vm_template_id}.yaml"   # Will use this later when cloning the template
  }

  agent {
    enabled = true
    timeout = "15m"
    type    = "virtio"
  }

  serial_device {
    device = "socket" # replaces this block of code ---> resource "null_resource" "enable_serial0" {***}
  }

  vga {
    type   = "serial0"
    memory = 16
  }
}

output "template_id" {
  value = proxmox_virtual_environment_vm.vm_template.vm_id
}

output "template_name" {
  value = proxmox_virtual_environment_vm.vm_template.name
}

output "template_node" {
  value = proxmox_virtual_environment_vm.vm_template.node_name
}


# resource "null_resource" "upload_user_data" {
#   connection {
#     type        = "ssh"
#     host        = var.proxmox_server_ip
#     user        = "root"
#     private_key = file(var.ssh_private_key_path)
#   }

#   provisioner "file" {
#     content     = local.cloud_init_userdata
#     destination = "/var/lib/vz/snippets/user-data-${var.vm_template_id}.yaml"
#   }
# }

# resource "null_resource" "apply_cicustom" {
#   depends_on = [null_resource.upload_user_data]

#   connection {
#     type        = "ssh"
#     host        = var.proxmox_server_ip
#     user        = "root"
#     private_key = file(var.ssh_private_key_path)
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "qm set ${var.vm_template_id} --cicustom 'user=local:snippets/user-data-${var.vm_template_id}.yaml'"
#     ]
#   }
# }

# resource "null_resource" "enable_serial0" {
#   depends_on = [null_resource.apply_cicustom]

#   connection {
#     type        = "ssh"
#     host        = var.proxmox_server_ip
#     user        = "root"
#     private_key = file(var.ssh_private_key_path)
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "qm set ${var.vm_template_id} --serial0 socket",
#       "qm set ${var.vm_template_id} --vga serial0"
#     ]
#   }
# }


# resource "null_resource" "convert_to_template" {
#   depends_on = [null_resource.apply_cicustom]

#   connection {
#     type        = "ssh"
#     host        = var.proxmox_server_ip
#     user        = "root"
#     private_key = file(var.ssh_private_key_path)
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "qm template ${var.vm_template_id}"
#     ]
#   }
# }
