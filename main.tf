terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

resource "proxmox_vm_qemu" "k8s-master" {
  name        = "k8s-master"
  target_node = "proxmox"
  vmid       = 300
  clone      = "ubuntu-template"
  full_clone = true

  ciuser    = var.ci_user
  cipassword = var.ci_password
  sshkeys   = file(var.ci_ssh_public_key)

  agent     = 1
  cores     = 2
  memory    = 2048
  os_type   = "cloud-init"
  bootdisk  = "scsi0"
  scsihw    = "virtio-scsi-pci"

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = "local"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = 10
          storage = "local"
        }
      }
    }
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot     = "order=scsi0"
  ipconfig0 = "ip=dhcp"
  
  lifecycle {
    ignore_changes = [ 
      network
    ]
  }
}

resource "proxmox_vm_qemu" "k8s-workers" {
  count       = var.vm_count
  name        = "k8s-worker-${count.index + 1}"
  target_node = "proxmox"
  vmid        = 301 + count.index
  clone       = "ubuntu-template"
  full_clone  = true

  ciuser    = var.ci_user
  cipassword = var.ci_password
  sshkeys   = file(var.ci_ssh_public_key)

  agent     = 1
  cores     = 2
  memory    = 2048
  os_type   = "cloud-init"
  bootdisk  = "scsi0"
  scsihw    = "virtio-scsi-pci"

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = "local"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = 10
          storage = "local"
        }
      }
    }
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot     = "order=scsi0"
  ipconfig0 = "ip=dhcp"
  
  lifecycle {
    ignore_changes = [ 
      network
    ]
  }
}

output "vm_info" {
  value = {
    master = {
      hostname = proxmox_vm_qemu.k8s-master.name
      ip_addr  = proxmox_vm_qemu.k8s-master.default_ipv4_address
    },
    workers = [
      for vm in proxmox_vm_qemu.k8s-workers : {
        hostname = vm.name
        ip_addr  = vm.default_ipv4_address
      }
    ]
  }
}

resource "null_resource" "update_hosts" {
  depends_on = [
    proxmox_vm_qemu.k8s-master,
    proxmox_vm_qemu.k8s-workers
  ]

  provisioner "local-exec" {
    command = <<EOT
      # Update /etc/hosts for master node
      if grep -q "${proxmox_vm_qemu.k8s-master.name}" /etc/hosts; then
        sed -i "s/.*${proxmox_vm_qemu.k8s-master.name}.*/${proxmox_vm_qemu.k8s-master.default_ipv4_address}  ${proxmox_vm_qemu.k8s-master.name}/" /etc/hosts
      else
        echo "${proxmox_vm_qemu.k8s-master.default_ipv4_address}  ${proxmox_vm_qemu.k8s-master.name}" >> /etc/hosts
      fi

      # Update /etc/hosts for worker nodes
      for worker in ${join(" ", [for worker in proxmox_vm_qemu.k8s-workers : "${worker.name}=${worker.default_ipv4_address}"])};
      do
        IFS='=' read -r name ip <<< "\$worker"
        if grep -q "\$name" /etc/hosts; then
          sed -i "s/.*\$name.*/\$ip  \$name/" /etc/hosts
        else
          echo "\$ip  \$name" >> /etc/hosts
        fi
      done
    EOT
  }
}


resource "local_file" "create_ansible_inventory" {
  depends_on = [
    proxmox_vm_qemu.k8s-master,
    proxmox_vm_qemu.k8s-workers
  ]

  content = <<EOT
[master-node]
${proxmox_vm_qemu.k8s-master.default_ipv4_address}

[worker-node]
${join("\n", [for worker in proxmox_vm_qemu.k8s-workers : worker.default_ipv4_address])}
EOT

  filename = "./inventory.ini"
}


resource "null_resource" "ansible_playbook" {
    depends_on = [local_file.create_ansible_inventory]
    provisioner "local-exec" {
        command = "sleep 60;ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./inventory.ini playbook-create-k8s-cluster.yml -u ${var.ci_user}"
    }
}