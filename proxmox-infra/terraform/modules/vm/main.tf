terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}
locals {
  vm_size = {
    "small" = {
      sockets = 2
      cores   = 2
      memory  = 2048
      disk    = "20G"
    }
    "medium" = {
      sockets = 2
      cores   = 2
      memory  = 4096
      disk    = "40G"
    }
    "large" = {
      sockets = 2
      cores   = 4
      memory  = 8192
      disk    = "80G"
    }
    "xlarge" = {
      sockets = 2
      cores   = 8
      memory  = 16384
      disk    = "160G"
    }
        "cpu-heavy" = {
      sockets = 4
      cores   = 4
      memory  = 6144
      disk    = "60G"
    }
  }
  operating_system = {
    "ubuntu" = {
      os = "ubuntu2404"
      type = "l26"
    }
    "fedora"  = {
      os = "fedora42"
      type = "l26"
    }
    "windows" = {
      os = "Win22"
      type = "win11"
    }
  }
}

resource "proxmox_vm_qemu" "vm-server" {
  target_node = "pve"
  name        = var.hostname
  desc        = var.description
  agent       = 1
  full_clone  = true
  clone       = local.operating_system[var.os].os
  cpu_type    = "host"
  numa        = true
  sockets     = local.vm_size[var.size].sockets
  cores       = local.vm_size[var.size].cores
  memory      = local.vm_size[var.size].memory
  boot        = "order=virtio0"
  onboot      = true
  os_type     = "cloud-init"
  qemu_os     = local.operating_system[var.os].type
  tags        = var.tags

  serial {
    id = 0
  }

  disks {
    virtio {
      virtio0 {
        disk {
          storage = "local-lvm"
          size    = local.vm_size[var.size].disk 
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
    id       = 0
  }

  # cloud-init config
  cicustom   = "user=local:snippets/${var.userdata}"
  ipconfig0  = format("ip=%s/24,gw=192.168.120.1", var.ip_address)
  nameserver = "192.168.120.1"

  lifecycle {
    ignore_changes = [desc,tags,network,disk,cicustom]
  }

}

