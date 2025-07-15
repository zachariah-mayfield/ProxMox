variable "proxmox_server_ip" {
  description = "Proxmox Server IP address (e.g.  10.10.10.25)"
  type        = string
}

variable "proxmox_node_name" {
  description = "Proxmox node hostname (e.g. corsair700d)"
  type        = string
}

# variable "proxmox_api_url" {
#   description = "Proxmox API endpoint, including port and /api2/json suffix (e.g. https://10.10.10.25:8006/api2/json)"
#   type        = string
# }

# variable "proxmox_api_token_id" {
#   description = "Proxmox API token ID in the format 'user@realm!name' (e.g. root@pam!terraform)"
#   type        = string
# }

variable "proxmox_api_token" {
  description = "Proxmox API token in the format 'user@realm!name=tokenid' (e.g. root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
  type        = string
  sensitive   = true
}

variable "vm_template_id" {
  description = "VM ID for the template"
  type        = number
  default     = 1111
}

variable "target_vm_id" {
  description = "target VM ID for the cloned VM"
  type        = number
  default     = 7777
}

variable "target_vm_name" {
  description = "Name for the cloned VM"
  type        = string
  default     = "automation-7777"
}

variable "mac_address" {
  description =  <<EOT
MAC address for the cloned VM. If null, mac_address is omitted (e.g. 'AA:BB:CC:DD:77:77'). 
If you need a unique MAC address, change this to a specific value.
EOT
  type        = string
  default     = null # Change to a unique MAC address if needed
}

variable "ip_address" {
  description = <<EOT
IP address for the cloned VM. Use 'dhcp' for DHCP or specify an IP address in CIDR notation 
(e.g. '192.168.1.240/24'). Or use 'dhcp'
EOT
  type    = string
  default = "dhcp" # Change to "dhcp" for DHCP
}

variable "gateway" {
  description = "Gateway IP address for the cloned VM. Ommit if using 'dhcp'."
  type    = string
  default = "dhcp" # Ommit if using "dhcp"
}

variable "cloud_init_root" {
  description = "cloud-init root"
  type        = string
}

variable "cloud_init_user" {
  description = "Cloud-init username"
  type        = string
}

variable "cloud_init_password" {
  description = "Plain-text password for cloud-init user"
  type        = string
  sensitive   = true
}

variable "storage_pool_disk" {
  description = "Proxmox storage pool name for VM disk (e.g. nvme_pool)"
  type        = string
  default     = "nvme_pool"
}

variable "storage_pool_cloudinit" {
  description = "Proxmox storage pool name for cloud-init snippets (e.g. local)"
  type        = string
  default     = "local"
}

variable "ssh_key_path" {
  description = "ssh key path"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key for Proxmox access - This will be set in the Azure DevOps pipeline as a variable."
  type        = string
}


variable "vm_mac_addresses" {
  description = "Optional MAC addresses per VM"
  type        = map(string)
  default     = {}
}

variable "vm_ip_addresses" {
  description = "Optional static IPs per VM (use 'dhcp' for dynamic)"
  type        = map(string)
  default     = {}
}

variable "vm_gateways" {
  description = "Optional gateways per VM (omit if using DHCP)"
  type        = map(string)
  default     = {}
}

variable vm_configs {
    type = map(object({
        target_vm_id        = number
        target_vm_name      = string
        memory       = number
        cpu_sockets  = number
        cpu_cores    = number
        disk_size    = number
        mac_address  = optional(string, null) # Optional MAC address, default is null
        ip_address   = optional(string, "dhcp") # Optional IP address, default is "dhcp"
        gateway      = optional(string, "dhcp") # Optional gateway, default
    }))
    default = {
        "vm-7777" = {
            target_vm_id        = 7777
            target_vm_name      = "automation-7777"
            memory       = 16384 # 16GB memory
            cpu_sockets  = 1
            cpu_cores    = 8
            disk_size    = 50
            #mac_address  = "AA:BB:CC:DD:77:77" # Optional MAC address, change if needed
            #ip_address   = "192.168.1.240/24"
            #gateway      = "192.168.1.254"
        }
        # "vm-8888" = {
        #     target_vm_id        = 8888
        #     target_vm_name      = "worker-8888"
        #     memory       = 8192
        #     cpu_sockets  = 1
        #     cpu_cores    = 4
        #     disk_size    = 50
        #     #mac_address  = "AA:BB:CC:DD:88:88" # Optional MAC address, change if needed
        #     #ip_address   = "dhcp" # Use "dhcp" for DHCP
        #     #gateway      = "dhcp" # Ommit if using "dhcp"
        # }
        # "vm-9999" = {
        #     target_vm_id        = 9999
        #     target_vm_name      = "worker-9999"
        #     memory       = 8192
        #     cpu_sockets  = 1
        #     cpu_cores    = 4
        #     disk_size    = 50
        #     #mac_address  = null # Optional MAC address, change if needed
        #     #ip_address   = "dhcp" # Use "dhcp" for DHCP
        #     #gateway      = "dhcp" # Ommit if using "dhcp"
        # }
    }
} 


# TFVARS EXAMPLE:

# vm_mac_addresses = {
#   "vm-7777" = "AA:BB:CC:DD:77:77"
#   "vm-8888" = "AA:BB:CC:DD:88:88"
# # "vm-9999" = null  # Optional, can be omitted or set to null
# }

# vm_ip_addresses = {
#   "vm-7777" = "192.168.1.240/24"
#   "vm-8888" = "dhcp"
# # "vm-9999" = "dhcp"  # Optional, can be omitted or set to "dhcp"
# }

# vm_gateways = {
#   "vm-7777" = "192.168.1.254"
#   # "vm-8888" gateway omitted or set to "dhcp"
#   # "vm-9999" gateway omitted or set to "dhcp"
# }