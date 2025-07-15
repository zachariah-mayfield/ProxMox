

***

# 📄 Proxmox Windows 11 Setup with ISO and Ventoy USB

***

This guide walks you through Copying Windows 11 installation files, and accessing ISO files from a Ventoy-powered USB drive for VM installation in Proxmox.

***

# 💾 Prepare USB with Windows ISO
# ✂️📋Copy the Windows 11 ISO to a USB Stick
You can use a tool like [Ventoy](https://www.ventoy.net/en/index.html) to boot directly from ISOs placed on the USB.

# ⬇️ Download VirtIO Drivers
To ensure Windows recognizes the virtual hardware in Proxmox (especially disk and network adapters), download the VirtIO driver ISO:

***

# 🔗 Windows VirtIO Driver:

🔗 [Proxmox virtual environment wiki for Windows VirtIO Drivers - Main Page](https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers)

🔗 [Windows VirtIO Driver Direct download link](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)

***

# 🔍 Detect and Mount Ventoy USB on Proxmox
# 📝 List Attached Devices
Run this to identify the USB partitions:
```bash
# bash

lsblk
```

You'll likely see output like this EXAMPLE: 
```java
sdc     8:32   1 119.5G  0 disk 
├─sdc1  8:33   1 119.5G  0 part  ← Ventoy data partition (exFAT)
└─sdc2  8:34   1   32MB  0 part  ← Ventoy boot partition (vfat)
```

# 🆕 Create a Mount Point:
```bash
# bash

mkdir -p /mnt/ventoy
```

# 🗄️ Mount the Data Partition (sdc1):
```bash
# bash

mount /dev/sdc1 /mnt/ventoy
```

# 👀 View Files on the USB:
```bash
# bash

ls -lh /mnt/ventoy
```

# ✂️📋Copy the ISO file(s) from the usb to the Proxmox server:
```bash
# bash

cp /mnt/ventoy/windows_11_pro.iso /var/lib/vz/template/iso/
cp /mnt/ventoy/windows_virtualization_drivers.iso /var/lib/vz/template/iso/
```

# ⏏️ safely eject - Umount USB:
```bash
# bash

umount -l /mnt/ventoy
```

## 🗄️ VirtIO storage drivers (needed during Windows installation)
virtio-win.iso/virtio-win/viostor/

## 🗄️ VirtIO network drivers
virtio-win.iso/NetKVM/w11/


## Automate the .env load
If you want to automatically load .env when you cd into your project folder, consider using direnv:

## Install: brew install direnv
```bash
# bash

brew install direnv
```

## Create .envrc file in your project:
```bash
# bash
# .envrc
touch .envrc
```
## Inside the .envrc file in your project
```bash
# bash

source .env
```

## Allow the .envrc file (security step)
```bash
# bash

direnv allow
```

## Once allowed, every time you cd into that directory, you’ll see:
```bash
# bash

direnv: loading .envrc
direnv: export +TF_VAR_pm_api_url +TF_VAR_pm_user +...
```

