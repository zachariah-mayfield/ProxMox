# 🧠 Kubernetes Cluster Bootstrap with Ansible

## This Ansible role fully automates the provisioning and configuration of a Kubernetes cluster, including:

- Initializing the control plane
- Joining worker nodes
- Installing the Flannel CNI plugin
- Handling conditional resets for failed joins
- Labeling worker nodes
- Ensuring idempotent, resilient, and fully hands-off setup

# 📂 File Structure Below

## 📁 Inventory Structure
## Ansible/inventory.yml
### This playbook assumes the following inventory setup:

```YAML
# yaml
all:
  children:
    proxmox:
      hosts:
        <IP_Address>:
          ansible_user: root
          ansible_host: <IP_Address>
          ansible_python_interpreter: /usr/bin/python3
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519
      vars:
        ansible_ssh_common_args: "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

    kubernetes_cluster:
      children:
        k8s_control_plane:
          hosts:
            k8s-ctrlr-8888:
              ansible_host: <IP_Address>
        k8s_worker_nodes:
          hosts:
            k8s-node-8000:
              ansible_host: <IP_Address>
            k8s-node-8100:
              ansible_host: <IP_Address>
      vars:
        ansible_user: root
        ansible_ssh_private_key_file: ~/.ssh/id_ed25519
        ansible_ssh_common_args: "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
```

## Ansible/playbook_install_and_configure_kubernetes.yml
```YAML
# yaml 
---
- name: Install and configure Kubernetes on Proxmox VMs
  hosts: kubernetes_cluster
  become: true
  become_method: sudo
  gather_facts: true
  roles:
    - install_and_configure_kubernetes
```

## ⚙️ Required Variables Ansible/roles/install_and_configure_kubernetes/vars/main.yml
```yaml
# yaml
control_plane_endpoint: <IP_Address>
node_name: "controler_node"
kube_user: "user_name"
```

## Ansible/roles/install_and_configure_kubernetes/tasks/main.yml
```yaml
# yaml
<CODE>
```

# 📌 Notes
### This role is idempotent and can be run multiple times without side effects.
### All kubectl operations on worker nodes are delegated to the control plane.
### The Flannel CNI configuration is written manually on worker nodes to ensure compatibility before joining.

# 🚀 How to run it:
```bash
# bash
cd /path/to/Ansible
ansible-playbook -i inventory.yml playbook_install_and_configure_kubernetes.yml -v
```

# 🧯 Troubleshooting
### If nodes are stuck in NotReady, rerun the playbook — it will reset and rejoin them automatically.

### If kubectl doesn't work after login, ensure the .bashrc or .profile has the correct KUBECONFIG line:
```bash
# bash
export KUBECONFIG=$HOME/.kube/config
kubectl get nodes -o wide
```

## If that dosent work restart by running the blelow: 

# Run the below commands to clean up the Kubernetes installation if it is stuck and you want to reset the cluster:
```bash
# bash
sudo rm /etc/apt/sources.list.d/kubernetes.list
sudo rm /etc/apt/sources.list.d/pkgs_k8s_io_core_stable_v1_30_deb.list
sudo rm -f /usr/share/keyrings/kubernetes-archive-keyring.gpg
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.asc
sudo apt autoremove --purge
sudo apt update
sudo kubeadm reset -f
sudo rm -rf /etc/kubernetes /var/lib/etcd /var/lib/kubelet /etc/cni/net.d
sudo systemctl restart containerd
```