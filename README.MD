# ProxMox Server Build

## Hardware Specifications:
- Case: CORSAIR 7000D AIRFLOW Full-Tower ATX PC Case, Black
- Power Supply: Corsair AX1600i 1600W Digital ATX Power Supply
- CPU Cooler: CORSAIR iCUE H170i ELITE CAPELLIX Liquid CPU Cooler - 33 Dynamic RGB LEDs - 140mm Fans - 420mm Radiator - COMMANDER CORE Smart Lighting Controller
- Motherboard: MSI MEG Z590 GODLIKE Gaming Motherboard (E-ATX, 11th/10th Gen Intel Core, LGA 1200 Socket, DDR4, PCIe 4, SLI/CFX, M.2 Slots, Thunderbolt, Wi-Fi 6E, Mystic Light RGB)
- Hard Drive(s): (4) Seagate FireCuda 530 2TB M.2 NVMe PCIE Internal SSD & (1) Crucial M550 2.5" 512GB SATA 6Gbps MLC Internal Solid State Drive (SSD) CT512M550SSD1
- CPU: Intel Core i9-11900K 11th Gen Rocket Lake 8 Core 3.5 GHz LGA 1200 125W CPU
- Memory: Corsair Dominator Platinum RGB 128GB (4x32GB) DDR4 3200 (PC4-25600) C16 1.35V Desktop Memory
- Video Card: MSI Gaming GeForce RTX 3060 12GB 15 Gbps GDRR6 192-Bit Gaming X Trio 
- Monitors: (2) SAMSUNG 49-inch Odyssey G9 Gaming Monitor | QHD, 240hz, 1000R Curved, QLED, NVIDIA G-SYNC & FreeSync | LC49G95TSSNXZA Model
- Keyboard: Razer BlackWidow V3 Pro Mechanical Wireless Gaming Keyboard
- Mouse: Razer Basilisk Ultimate Hyperspeed Wireless Gaming Mouse w/ Charging Dock
- Gaming Controler: Xbox Wireless Controller – Electric Volt for Xbox Series X and charging Dock 
- (2) Ergotron – HX Single Ultrawide Monitor Arm, VESA Wall Mount – for Monitors Up to 49 Inches, 20 to 42 lbs, Less Than 6 Inch Display Depth 

# 📄 How to set up Proxmox on a or Server or Desktop - and special settings for a Laptop
This guide walks you through expanding your Proxmox LVM

# 🧱 Resize LVM in Proxmox
To reclaim space from the `/dev/pve/data` volume and allocate it to `/dev/pve/root`, follow these steps:
```bash
# bash

lvremove /dev/pve/data
lvresize -l +100%FREE /dev/pve/root
resize2fs /dev/mapper/pve-root
```

1. **Create and clone the repository:**
```bash
# bash

gh repo create ProxMox --public --description "Ansible playbook to format and mount NVMe drives on Proxmox"
git clone git@github.com:zachariah-mayfield/ProxMox.git
```

2. **Create the Ansible directory structure:**
```bash
# bash

cd /Users/zachariah-mayfield/GitHub/Main/ProxMox
mkdir -p roles/format_and_mount/tasks
touch inventory.ini playbook.yml roles/format_and_mount/tasks/main.yml
```

3. **Install Ansible and verify version:**
```bash
# bash

brew install ansible
ansible --version
```

4. **Copy your public key to the clipboard on MacBook:**
```bash
# bash

ls ~/.ssh/
cat ~/.ssh/id_ed25519.pub
```

5. **Fix SSH Key Auth on Proxmox**
```bash
# bash

mkdir -p /root/.ssh
chmod 700 /root/.ssh
```

6. **Add your MacBook’s public key (the whole single line) on Proxmox server on a new line BELOW the existing key in that file:**
```bash
# bash

nano /root/.ssh/authorized_keys
```

7. **Set permissions on Proxmox:**
```bash
# bash

chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
```

8. **Test SSH connection to Proxmox server from MacBook:**
```bash
# bash

ssh -i ~/.ssh/id_ed25519 root@192.168.1.250
```

9. **Run Ansible playbook ping test:**
```bash
# bash

ansible -i inventory.ini proxmox -m ping
```


# 📄 Disable enterprise repo

# 🛠️ Edit your APT sources list for Proxmox and Disable the Enterprise Ceph and pve Repo:
```bash
# bash

nano /etc/apt/sources.list.d/ceph.list 
# deb https://enterprise.proxmox.com/debian/ceph-quincy bookworm enterprise
nano /etc/apt/sources.list.d/pve-enterprise.list
# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
```
💾 Save and exit

***

# 📄 Enable the no-subscription repo:

# 🛠️ and Add the no-subscription repo to /etc/apt/sources.list: Edit this file /etc/apt/sources.list

Add this line at the bottom if it's not already there:
```bash
# bash

nano /etc/apt/sources.list
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
```

***

# 🆕 Update the package list and Install parted:**:
```bash
# bash

apt update
apt install -y parted
```

***

✅ Optional: Remove annoying update warnings in Web UI
To remove the red “No valid subscription” notice:
```bash
# bash

sed -i.bak "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
systemctl restart pveproxy
```
⚠️ Note: This gets overwritten with updates, so you might need to reapply after upgrades.
***

# 🛠️ Edit this file and the following two values if you are installing Proxmox on a laptop and you don't want the server to die when closing the lid:

**/etc/systemd/logind.conf**
```bash
# bash

HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
```
![image](https://github.com/user-attachments/assets/18356c5b-e69f-476e-84ea-2691c961a015)

# 🔄 Restart the login service:
```bash
# bash

systemctl restart systemd-logind.service
```   

# 🛠️ Edit this file and the following value if you are installing Proxmox on a laptop and you don't want the screen to burnout on the laptop for being left on:
**/etc/default/grub**

Also while in the grub file you will want to Ensure IOMMU is enabled
```bash
# bash

GRUB_CMDLINE_LINUX="consoleblank=300"
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on"
```
![image](https://github.com/user-attachments/assets/e035b2c8-c3d8-4433-9124-dd372ee642d0)

# ⬆️ Update Grub
```bash
# bash

update-grub
```

***

# 📦Install wsdd for Windows discorvery
```bash
# bash

apt update
sudo apt install wsdd
```

# Commands for how to check logs for Cloud-Init and make sure it installed some of the applications on the new VM:
```bash
# bash

sudo cloud-init status

sudo cloud-init status --long

sudo cloud-init schema --system

sudo cloud-init query

sudo cloud-init modules --mode=config

sudo cloud-init modules --mode=final

sudo systemctl restart cloud-init

sudo journalctl -fu cloud-init

qm cloudinit dump <vm_id> user

qm config <vm_id> | grep ide2

qm config <vm_id> | grep cicustom

grep -i "error" /var/log/cloud-init.log

grep -i "user-data" /var/log/cloud-init.log

sudo tail -n 100 /var/log/cloud-init.log

sudo systemctl status qemu-guest-agent

systemctl status qemu-guest-agent docker
```

# Terraform Proxmox provider Documentation: 
- (Terraform Provider - BPG/Proxmox - Resource virtual_environment_file)[https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_file]
- (Terraform Provider - BPG/Proxmox - Resource virtual_environment_vm)[https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm]
- (Terraform Provider - Telmate/Proxmox - Resource cloud_init)[https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/guides/cloud_init]
- (Terraform Provider - Telmate/Proxmox - Resource vm_qemu)[https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu]