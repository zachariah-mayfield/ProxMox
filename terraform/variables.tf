variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID (e.g., root@pam!terraform)"
  type        = string
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret (e.g., xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
  type        = string
  sensitive   = true
}

variable "pm_api_token" {
  description = "Proxmox API token (e.g., root@pam!terraform@xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
  type        = string
  sensitive   = true
}