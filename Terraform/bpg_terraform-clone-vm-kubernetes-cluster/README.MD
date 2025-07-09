# Step 0 - SSH into each of the servers that will be running Kubernetes:
### Remove any previous SSH Key gens
```bash
# bash 
# Do this for each node and controler.
ssh-keygen -R <ip_of_X_node>
```

### SSH into each of the nodes using a different shell window.
```bash
# bash
ssh -i ~/.ssh/id_ed25519 root@<ip_of_controler_node>
ssh -i ~/.ssh/id_ed25519 root@<ip_of_node>
ssh -i ~/.ssh/id_ed25519 root@<ip_of_node>
```

# Step 1 - Install and configure Containerd and prerequisites: 
### Install the QEMU Guest Agent: on the Kubernetes Controller and all other nodes.
```bash
# bash
sudo apt install qemu-guest-agent
```

### Install Kubernetes cluster "Containerd" - to utilize the containerd runtime.
```bash
# bash
sudo apt install containerd
```

### Create the initial configuration folder and file:
```bash
# bash
sudo mkdir /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
```

### Edit the config to enable SystemdCgroup within the configuration for this cluster to work properly
```bash
# bash
sudo nano /etc/containerd/config.toml
```

### In that file, find the following line of text:
```bash
# bash
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
```

### Underneath that, find the SystemdCgroup option and change it to true like this:
```bash
# bash
SystemdCgroup = true
```

# Step 2 - Disable Swap - Kubernetes requires swap to be disabled.
### To turn off swap, we can run the following command:
```bash
# bash
sudo swapoff -a
```

### Edit the /etc/fstab file and comment out the line that corresponds to swap (if present). This will help ensure swap doesn’t end up getting turned back on after reboot.
```bash
# bash
sudo nano /etc/fstab 
```

# Step 3 - Enable Bridging.
### To enable bridging edit the following config file: look for the following line: #net.ipv4.ip_forward=1 Uncomment that line by removing the # symbol in front of it.
```bash
# bash
sudo nano /etc/sysctl.conf
```

# Step 4 - Enable br-netfilter
### ### To enable br-netfilter edit the following config file: 
```bash
# bash
sudo nano /etc/modules-load.d/k8s.conf
```
### Add the following to that file (the file should actually be empty at first):
```bash
# bash
br_netfilter
```

# Step 5 - Reboot your servers
### Reboot each of your instances to ensure all of our changes so far are in place:
```bash
# bash
sudo reboot
```

# Step 6 - Install Kubernetes - Install the packages that are required for Kubernetes:
### Install the required GPG key:
```bash
# bash
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```

### Install Kubernetes packages:
```bash
# bash
sudo apt install kubeadm kubectl kubelet
```

# Step 7 - Initialize the Kubernetes Cluster
### After ensuring that all of the Kubernetes steps are completely done up until this point, you can now initialize the Kubernetes Cluster: After the initialization finishes, you should see at least four commands printed within the output
```bash
# bash
# Be sure to change your control-plane-endpoint=<Your_IP_Address_for_Your_Kubernetes_Controler> && --node-name <Your_Node_Name_for_Your_Kubernetes_Controler>
# Below are my examples:
sudo kubeadm init --control-plane-endpoint=192.168.1.241 --node-name k8s-ctrlr-8888 --pod-network-cidr=10.244.0.0/16
```

### Three commands will be shown in the output from the previous command, and these commands will give our user account access to manage our cluster:
```bash
# bash
# These commands allow you to manage the cluster, without needing to use the root account to do so.
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
suod chown $(id -u):$(id -g) $HOME/.kube/config
```

### Install the Flannel overlay network run the following command:
```bash
# bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

# Step 8 - Adding Node to the Kubernetes Cluster
### The join command, which you will receive from the output once you initialize the cluster, can be ran on your node instances now to get them joined to the cluster. The following command will help you monitor which nodes have been added to the controller (it can take several minutes for them to appear):
```bash
# bash
kubectl get nodes
```

### If for some reason the join command has expired, the following command will provide you with a new one:
```bash
# bash
kubeadm token create --print-join-command
```

# Step 9 - Deploying a container to the Kubernetes Cluster:
### Create the file pod.yml with the following contents:
```YAML
# yaml
apiVersion: v1
kind: Pod
metadata:
Chapter 18 25
 
name: nginx-example
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: linuxserver/nginx
      ports:
        - containerPort: 80
          name: "nginx-http"
```

### Apply the YAML file with the following command:
```bash
# bash
kubectl apply -f pod.yml
```

# To check the status of this deployment run the following command:
```bash
# bash
kubectl get pods
```

# Step 10 - Create a NodePort Service to access the container
### Create the following file as service-nodeport.yml:
```YAML
# yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-example
spec:
  type: NodePort
  ports:
    - name: http
      port: 80
      nodePort: 30080
      targetPort: nginx-http
  selector:
app: nginx
```

### Apply the service-nodeport.yml file with the following command:
```bash
# bash
kubectl apply -f service-nodeport.yml
```

### To check the status of the service deployment, run the following command:
```bash
# bash
kubectl get service
```

# And now, you have your very own Kubernetes cluster, congratulations!