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
    username     = "root" # Use the username that has access to Proxmox
    private_key = trimspace(file("~/.ssh/id_ed25519"))  # ✅ This should be the **private** key! # this version does not work with Azure DevOps
    # private_key  = trimspace(file("/home/ubuntu/.ssh/id_ed25519")) # ✅ This should be the **private** key! # this version works with Azure DevOps
  }
}

# RENDER cloud-init YAML from template with variables
locals {
  rendered_user_data = {
    for vm_key, config in var.vm_configs : vm_key => templatefile("${path.module}/templates/user-data.tpl", {
      vm_name             = config.target_vm_name
      cloud_init_user     = var.cloud_init_user
      cloud_init_root     = "root"
      cloud_init_password = bcrypt(var.cloud_init_password)
      cloudinit_ssh_key   = trimspace(file(var.ssh_key_path))
      cloudinit_autologin = true
    })
  }
}

# WRITE the rendered user-data YAML to a local file
resource "local_file" "rendered_user_data" {
  for_each = var.vm_configs

  content  = local.rendered_user_data[each.key]  # This is a string
  filename = "${path.module}/cloudinit/user-data-${each.value.target_vm_name}.yml"
}


resource "proxmox_virtual_environment_file" "user_data" {
  for_each     = var.vm_configs

  content_type = "snippets"
  datastore_id = "local" # use local storage for cloud-init snippets
  node_name    = var.proxmox_node_name

  source_file {
    path = local_file.rendered_user_data[each.key].filename  # Corrected
  }

  overwrite = true
}

locals {
  full_vm_configs = {
    for vm_name, cfg in var.vm_configs :
    vm_name => merge(cfg, {
      mac_address = lookup(var.vm_mac_addresses, vm_name, null)
      ip_address  = lookup(var.vm_ip_addresses, vm_name, "dhcp")
      gateway     = lookup(var.vm_gateways, vm_name, "dhcp")
    })
  }
}


resource "proxmox_virtual_environment_vm" "clone_vm" {
  for_each = local.full_vm_configs

  name      = each.value.target_vm_name
  node_name = var.proxmox_node_name
  vm_id     = each.value.target_vm_id
  on_boot   = false
  started   = true

  clone {
    vm_id     = var.vm_template_id
    full      = true
    node_name = var.proxmox_node_name
  }

  cpu {
    type    = "host"
    sockets = each.value.cpu_sockets
    cores   = each.value.cpu_cores
    numa    = true        # Enable NUMA (especially for multi-core VMs)
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "nvme_pool"
    interface    = "scsi0"
    size         = each.value.disk_size
    aio          = "io_uring"
    cache        = "none"
    discard      = "ignore"
    backup       = false          # Optional, set true if needed
    replicate    = false          # Optional, set true if needed
  }

  network_device {
    model  = "virtio"
    bridge = "vmbr0"
    mac_address = each.value.mac_address # If null, mac_address is omitted
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
        address = each.value.ip_address
        gateway = each.value.ip_address == "dhcp" ? null : each.value.gateway
      }
    }

    datastore_id      = "local"
    user_data_file_id = proxmox_virtual_environment_file.user_data[each.key].id

    user_account {
      username = var.cloud_init_user
      password = bcrypt(var.cloud_init_password)
      keys     = [trimspace(file(var.ssh_key_path))]
    }
  }
}

output "vm_names" {
  value = { for k, vm in proxmox_virtual_environment_vm.clone_vm : k => vm.name }
}

output "vm_ids" {
  value = { for k, vm in proxmox_virtual_environment_vm.clone_vm : k => vm.vm_id }
}

output "vm_mac_addresses" {
  value = { for k, vm in proxmox_virtual_environment_vm.clone_vm : k => vm.network_device[0].mac_address }
}

output "vm_ips" {
  value = { for k, vm in proxmox_virtual_environment_vm.clone_vm : k => try(vm.ipv4_addresses[1], null) }
}
