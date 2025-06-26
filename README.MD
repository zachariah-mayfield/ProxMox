# 📄 Proxmox Initial Setup on a Laptop
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

