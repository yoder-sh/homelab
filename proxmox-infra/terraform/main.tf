terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc8"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "yoder-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
    encrypt      = true
    #use_lockfile = true # Waiting on Tofu v1.10
  }
}

provider "proxmox" {
  pm_api_url          = "https://192.168.120.10:8006/api2/json"
  pm_api_token_id     = "terraform-prov@pve!terraform-api"
  pm_api_token_secret = data.aws_ssm_parameter.proxmox_api_token.value
  pm_tls_insecure     = true
}

provider "aws" {
  region = "us-east-1" 
}

locals {
  vm_files  = fileset(".", "vms/*.yaml")
  vm        = { for file in local.vm_files : basename(file) => yamldecode(file(file)) }
}

module "vm_resource" {
  source      = "./modules/vm"
  for_each    = local.vm
  hostname    = each.value.hostname
  description = each.value.description
  os          = each.value.os
  size        = each.value.size
  ip_address  = each.value.ip_address
  tags        = each.value.tags
  userdata    = each.value.userdata
}