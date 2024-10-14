#!/bin/bash

# prompt user to choose
clear
echo "#####################  CREATE VM TEMPLATE ON PROXMOX VE  ###########################"
read -p "Please enter image URL: " CLOUD_IMAGES_URL
read -p "Please enter the image name: " IMAGE_NAME
read -p "Please enter the VM ID: " VM_ID
read -p "Please enter the VM Name: " VM_NAME
read -p "Please enter the Storage: " STORAGE
read -p "Enter Cloud init user name: " USER_NAME
read -sp "Enter Cloud init user password: " USER_PASSWORD
echo ""
read -p "Enter Cloud init SSH Public Key Path: " CLOUDINIT_SSH_PUBKEY_LOCATION
echo ""
echo "############################  STARTING  ###################################"

apt update -y &>/dev/null
apt install libguestfs-tools -y &>/dev/null

IMAGE_PATH="./${IMAGE_NAME}"
# Download target file
ls ${IMAGE_PATH} &>/dev/null
if [ $? -eq 0 ]; then
  # If file exists
  echo "Image file already exists, continuing....."
else
    # If file doesn't exist, download
    echo "Downloading the image....."
    if ! wget -O "${IMAGE_NAME}" "${CLOUD_IMAGES_URL}" --show-progress; then
      echo "Failed to download the image."
      exit 1
    fi
fi

echo "Download complete! saved in ${IMAGE_PATH}"

qemu-img resize ${IMAGE_NAME} 10G &>/dev/null
virt-customize -a ${IMAGE_NAME} --install qemu-guest-agent --truncate /etc/machine-id &>/dev/null
qm create ${VM_ID} --name  ${VM_NAME} --cores 1 --memory 1024 --net0 virtio,bridge=vmbr0 &>/dev/null
qm disk import ${VM_ID} ${IMAGE_NAME} ${STORAGE} &>/dev/null
qm set ${VM_ID} --scsihw virtio-scsi-pci --scsi0 ${STORAGE}:${VM_ID}/vm-${VM_ID}-disk-0.raw &>/dev/null
qm set ${VM_ID} --ide0 ${STORAGE}:cloudinit &>/dev/null
qm set ${VM_ID} --boot c --bootdisk scsi0 &>/dev/null
qm set ${VM_ID} -agent 1 &>/dev/null
qm set ${VM_ID} --serial0 socket &>/dev/null
qm set ${VM_ID} --hotplug network,usb,disk &>/dev/null
qm set ${VM_ID} --ipconfig0 ip=dhcp &>/dev/null
qm set ${VM_ID} --ciuser ${USER_NAME} &>/dev/null
qm set ${VM_ID} --cipassword "${USER_PASSWORD}" &>/dev/null
qm set ${VM_ID} --sshkeys ${CLOUDINIT_SSH_PUBKEY_LOCATION} &>/dev/null
qm template "${VM_ID}" &>/dev/null
echo ""
echo ""
echo "VM ${VM_NAME} has been converted to a template!!!"
echo "#####################  FINISH  ###########################"

