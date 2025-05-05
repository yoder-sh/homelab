# Ansible Role: libvirt_vm

An Ansible role for creating and configuring multiple virtual machines using libvirt and KVM.

## Features

- Creates multiple VMs from a single playbook run
- Uses cloud-init for VM configuration
- Supports direct-attached (bridged) networking
- Configures user accounts and SSH key access
- Each VM can have custom specifications (memory, CPU, disk size)
- Waits for VMs to become available and reports their IP addresses
- Built-in QEMU guest agent support for better VM management

## Requirements

- A host system with libvirt and KVM support
- The following packages should be pre-installed:
  - qemu-kvm
  - libvirt-daemon-system
  - libvirt-clients
  - bridge-utils
  - virtinst
  - libguestfs-tools
  - python3-libvirt
  - whois (for mkpasswd command on control node)
  - genisoimage (for cloud-init ISO creation)
- libvirtd service should be running
- Properly configured network bridge interface for direct-attached networking
- Ansible 2.9 or higher

**Note:** This role assumes required packages are installed and will display helpful error messages if a step fails due to missing dependencies.

## Role Variables

### Common Variables (can be overridden)

| Variable | Default | Description |
|----------|---------|-------------|
| `install_dependencies` | `true` | Whether to install required packages |
| `debug_mode` | `true` | Enable detailed debugging output |
| `vm_storage_pool` | `"default"` | Name of the libvirt storage pool to use |
| `vm_memory_mb` | `2048` | Default memory allocation (MB) |
| `vm_vcpus` | `2` | Default number of vCPUs |
| `vm_disk_size_gb` | `20` | Default disk size (GB) |
| `vm_os_variant` | `"debian12"` | OS variant for libvirt |
| `vm_image_url` | *debian URL* | URL to download base cloud image |
| `vm_image_checksum` | *sha512 hash* | Checksum for image verification |
| `vm_generate_passwords` | `true` | Generate random passwords for VMs |
| `vm_domain` | `""` | Domain suffix for VM FQDNs |
| `vm_network_set` | `"bridged-network"` | Default network to use |
| `vm_packages` | `[vim, python3, sudo]` | Default packages to install |
| `vm_ssh_pub_key` | `false` | Whether to use SSH public key auth |
| `vm_ssh_pub_key_path` | `"~/.ssh/id_rsa.pub"` | Path to SSH public key |
| `vm_disable_ssh_password` | *not set* | Disable password authentication |
| `wait_for_ip` | `true` | Wait for VM to get an IP address |
| `display_summary` | `true` | Display summary of created VMs |

### Per-VM Configuration Options

When defining VMs in the `vms` list, each VM can have the following properties:

| Property | Default | Description |
|----------|---------|-------------|
| `name` | *Required* | Name of the VM (required) |
| `memory_mb` | `vm_memory_mb` | Memory allocation in MB |
| `vcpus` | `vm_vcpus` | Number of virtual CPUs |
| `disk_size_gb` | `vm_disk_size_gb` | Disk size in GB |
| `storage_pool` | `vm_storage_pool` | Storage pool to use |
| `network` | `vm_network_set` | Network to connect to |
| `packages` | `vm_packages` | Packages to install |
| `ssh_pub_key` | `vm_ssh_pub_key` | Use SSH public key authentication |
| `ssh_pub_key_path` | `vm_ssh_pub_key_path` | Path to SSH public key |
| `disable_ssh_password` | `vm_disable_ssh_password` | Disable password authentication |
| `domain` | `vm_domain` | Domain suffix for FQDN |


## Example Playbook

```yaml
---
# create_vms.yml
- name: Create and configure VMs using libvirt
  hosts: kvm_host
  become: true
  
  vars:
    # Common settings for all VMs
    vm_image_url: "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
    vm_image_checksum: "sha512:afcd77455c6d10a6650e8affbcb4d8eb4e81bd17f10b1d1dd32d2763e07198e168a3ec8f811770d50775a83e84ee592a889a3206adf0960fb63f3d23d1df98af"
    vm_ssh_pub_key: true
    vm_disable_ssh_password: true
    debug_mode: true
    
    # List of VMs to create
    vms:
      - name: "jumphost"
        memory_mb: 4096
        vcpus: 2
      
      - name: "webserver"
        memory_mb: 2048
        vcpus: 2
        packages:
          - nginx
          - php-fpm
          
      - name: "database"
        memory_mb: 8192
        vcpus: 4
        disk_size_gb: 50
        packages:
          - postgresql
  
  roles:
    - role: libvirt_vm
```

## Troubleshooting

### IP Address Detection

To properly detect VM IP addresses, the role uses the `virsh domifaddr` command with the `--source agent` parameter. This requires:

1. The QEMU guest agent to be installed in the VM (included in the default packages)
2. The guest agent to be running in the VM
3. The VM to have a proper network configuration

If IP detection fails, check that:
- The guest agent is installed and running: `systemctl status qemu-guest-agent`
- The VM has a valid network configuration
- The VM can reach the DHCP server 

You may need to restart the guest agent after VM creation: `systemctl restart qemu-guest-agent`

### VM Networking

This role supports different network types:
- Bridge networks (for VMs to appear on your physical network)
- NAT networks (for isolated VMs with outbound internet access)
- Isolated networks (for completely internal VM networks)

To use a bridge network, create it first in libvirt:

```
virsh net-define bridged-network.xml
virsh net-start bridged-network
virsh net-autostart bridged-network
```

With a sample XML like:

```xml
<network>
  <name>bridged-network</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
```

### Storage Pool Configuration

Make sure your storage pool is properly defined and active:

```
virsh pool-list --all
virsh pool-info vm-storage-pool
```

Create a storage pool if needed:

```
virsh pool-define-as vm-storage-pool dir --target /var/lib/libvirt/images/vms
virsh pool-build vm-storage-pool
virsh pool-start vm-storage-pool
virsh pool-autostart vm-storage-pool
```

## License

MIT

## Author Information

Created by Zack Yoder, 2025