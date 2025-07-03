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
  default     = 7777
}

variable "target_vm_id" {
  description = "target VM ID for the cloned VM"
  type        = number
  default     = 7111
}

variable "target_vm_name" {
  description = "Name for the cloned VM"
  type        = string
  default     = "clone-vm-7111"
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
