variable "proxmox_api_url" {
  type = string
}

variable "proxmox_user" {
  type = string
}

variable "proxmox_password" {
  type = string
  sensitive = true
}

variable "ci_user" {
  type = string
}

variable "ci_password" {
  type = string
  sensitive = true
}

variable "ci_ssh_public_key" {
  type = string
}

variable "ci_ssh_private_key" {
  type = string
}

variable "web-count" {
  type = number
}