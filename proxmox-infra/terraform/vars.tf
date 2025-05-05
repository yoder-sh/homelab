# Retrieve the SecureString from AWS Parameter Store
data "aws_ssm_parameter" "proxmox_api_token" {
  name = "/homelab/proxmox/api-key"
  with_decryption = true
}
data "aws_ssm_parameter" "proxmox_endpoint" {
  name = "/homelab/proxmox/endpoint"
  with_decryption = true
}

data "aws_ssm_parameter" "mbp_ssh_public_key" {
  name = "/homelab/ssh-keys/mbp-public-key"
  with_decryption = true
}

data "aws_ssm_parameter" "ansible_ssh_public_key" {
  name = "/homelab/ssh-keys/ansible-public-key"
  with_decryption = true
}

variable "proxmox_api_endpoint" {
  description = "Proxmox API Endpoint"
  default     = "https://192.168.120.10:8006"
}