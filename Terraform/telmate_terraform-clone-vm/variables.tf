variable "proxmox_server_ip" {
  description = "Proxmox Server IP address (e.g.  10.10.10.25)"
  type        = string
}

variable "proxmox_node_name" {
  description = "Proxmox node hostname (e.g. corsair700d)"
  type        = string
}

variable "proxmox_api_url" {
  description = "Proxmox API endpoint, including port and /api2/json suffix (e.g. https://10.10.10.25:8006/api2/json)"
  type        = string
}

# API Token ID in the format "user@realm!token_name
variable "proxmox_api_token_id" {
  description = "Proxmox API token ID in the format 'user@realm!name' (e.g. root@pam!terraform)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token in the format 'user@realm!name=tokenid' (e.g. root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
  type        = string
  sensitive   = true
}

variable "vm_template_id" {
  description = "VM ID for the template"
  type        = number
  default     = 7000
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

variable "ssh_key_path" {
  description = "ssh_key_path"
  type        = string
}

variable "cloud_init_root" {
  description = "cloud-init root"
  type        = string
}

variable "cloud_init_user" {
  description = "cloud-init user"
  type        = string
}

variable "cloud_init_password" {
  description = "cloud-init password"
  type        = string
}

