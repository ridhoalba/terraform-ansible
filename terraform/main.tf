resource "proxmox_vm_qemu" "MegadataWeb" {
  count = var.vm-count
  target_node = "pve"
  name = "website-${count.index + 1}"
  vmid = 200 + (count.index + 1)
  desc = "Sever dari website MegadataWeb"
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
  ipconfig0 = "ip=dhcp"

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

output "vm_info" {
  value = [
    for vm in proxmox_vm_qemu.MegadataWeb: {
      hostname = vm.name
      ip-addr = vm.default_ipv4_address
    }
  ]
}


