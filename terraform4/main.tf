resource "proxmox_vm_qemu" "website1" {  
  count = var.vm_count
  target_node = "pve"

  name = "web-app-${count.index + 1}"
  vmid = 110 + (count.index + 1)
  desc = "website dengan package web server apache2 dan nanti digabungkan dengan container yang berisi package database mysql"
  clone = "ubuntu-jammy"
  full_clone = true

  os_type = "cloud_init"
  cloudinit_cdrom_storage = "local-lvm"

  ciuser = var.ci_user
  cipassword = var.ci_password
  sshkeys = file(var.ci_ssh_public_key)

  cores = 1
  memory = 1024
  agent = 1

  bootdisk = "scsi0"
  scsihw = "virtio-scsi-pci"
  ipconfig0 = "ip=192.168.0.${250 + (count.index + 1)}/24,gw=192.168.0.1"

  disk {
    size = "10G"
    type = "scsi"
    storage = "local-lvm"
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [ 
        network
     ]
  }
}

resource "proxmox_lxc" "web-app-container" {
  count = var.ct_count
  target_node = "pve"
  vmid = 110 + (count.index + 1)
  hostname = "web-app-ct-${count.index + 1}"
  password = "Password"
  ssh_public_keys = file(var.ci_ssh_public_key)
  ostemplate = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
  cores = 1
  memory = 1024
  unprivileged = true
  start = true
  features {
    nesting = true
    fuse = true
    mount = "nfs;cifs"
  }

  rootfs {
    storage = "local-lvm"
    size = "10GB"
  }

  network {
    name = "eth0"
    bridge = "vmbr0"
    ip = "192.168.0.${252 + (count.index + 1)}/24"
    gw = "192.168.0.1"
    firewall = true
  }
}

output "web-app_info" {
  value = [
    for web-app in proxmox_vm_qemu.website1: {
        hostname = web-app.name
        ip-addr = web-app.default_ipv4_address
    }
  ]
}

output "web-app-container-info" {
  value = [
    for web-app-ct in proxmox_lxc.web-app-container: {
        hostname = web-app-ct.hostname
        ip-addr = web-app-ct.network[0].ip
    }
  ]
}