#!/bin/bash

# run this to target hosts:
# ssh root@192.168.120.10 'bash -s' < /Users/yoderzack/Git/homelab/proxmox-infra/scripts/template_deploy.sh




fedoraImageFilename=Fedora-Cloud-Base-Generic-42-1.1.x86_64.qcow2
fedoraImageBaseURL=https://download.fedoraproject.org/pub/fedora/linux/releases/42/Cloud/x86_64/images/
fedoraImageURL=https://download.fedoraproject.org/pub/fedora/linux/releases/42/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-42-1.1.x86_64.qcow2
scriptTmpPath=/tmp/proxmox-scripts
proxmoxTemplateID=9001
templateName=fedora42

init () {
    clean
    mkdir -p $scriptTmpPath
    vmDiskStorage=local
    cd $scriptTmpPath
}

getImage () {
    local _img=$scriptTmpPath/$fedoraImageFilename
    local imgSHA256SUM=$(curl -s $fedoraImageBaseURL/SHA256SUMS | grep $fedoraImageFilename | awk '{print $1}')
    if [ -f "$_img" ] && [[ $(sha256sum $_img | awk '{print $1}') == $imgSHA256SUM ]]
    then
        echo "The image file exists and the signature is OK"
    else
        wget $fedoraImageURL -O $_img
    fi
    
    #sudo cp $_img $fedoraImageFilename
}

createProxmoxVMTemplate () {
    #sudo qm destroy $proxmoxTemplateID --purge || true
    sudo qm create $proxmoxTemplateID --name $templateName --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
    sudo qm set $proxmoxTemplateID --virtio0 $vmDiskStorage:0,import-from=$scriptTmpPath/$fedoraImageFilename
    sudo qm set $proxmoxTemplateID --boot c --bootdisk virtio0
    sudo qm set $proxmoxTemplateID --ide2 $vmDiskStorage:cloudinit
    sudo qm set $proxmoxTemplateID --serial0 socket --vga serial0
    sudo qm set $proxmoxTemplateID --agent enabled=1,fstrim_cloned_disks=1
    sudo qm template $proxmoxTemplateID
}

clean () { 
    rm -rf $scriptTmpPath 
}

init
getImage
createProxmoxVMTemplate
clean