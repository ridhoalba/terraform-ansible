resource "proxmox_vm_qemu" "web" {
  count = var.web-count
  target_node = "pve"
  name = "web-${count.index + 1}"
  vmid = 250 + (count.index + 1)
  desc = "web"
  clone = "ubuntu-jammy"
  full_clone = true

  os_type = "cloud-init"
  cloudinit_cdrom_storage = "local-lvm"

  ciuser = var.ci_user
  cipassword = var.ci_password
  sshkeys = file(var.ci_ssh_public_key)

  cores = 1
  memory = 1024
  agent = 1

  bootdisk = "scsi0"
  scsihw = "virtio-scsi-pci"
  ipconfig0 = "ip=192.168.0.${12 + (count.index + 1)}/24,gw=192.168.0.1"

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

output "web_info" {
  value = [
    for web in proxmox_vm_qemu.web: {
      hostname = web.name
      ip-addr = web.default_ipv4_address
    }
  ]
}


