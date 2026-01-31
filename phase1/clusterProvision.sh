#!/bin/bash
#Controlplane node provisioning

#Disable swap on ALL nodes and persist across reboots
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

#Load kernel modules for network/storage
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

#Configure sysctl to persist through a reboot
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

#Update package list and pre-reqs
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

#Add Docker GPG Key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

#Download K8s GPG Key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

#Setup Docker repo
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#Add the K8 repo
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Install the containerd package
sudo apt-get update
sudo apt-get install -y containerd.io
sleep 5

#Configure containerd to use the cgroup driver
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

#Restart containerd to apply then validate
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl status containerd
sleep 5

#Update apt package and install kubelet, kubeadm, kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sleep 5

#Enable the kubelet service
sudo systemctl enable --now kubelet

#Lock kube* components so not updated during node updates then validate the version
sudo apt-mark hold kubelet kubeadm kubectl
kubeadm version -o short
sleep 2

#Initialize the cluster. This uses the Cilium industry standard CIDR block
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

#Follow the instructions from the init output. Two specifically: Make the directory and grab the join token. Both are provided by the output of initializing your cluster
echo “Follow the instructions provided in the init output from initializing your cluster. They are the mkdir three command syntax as well as the join token commands. Keep your terminal open until all nodes have been joined to the cluster and are showing as ready”

#Worker Nodes provisioning
#Load Kernel Modules
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

#Configure sysctl networking
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

#Add pre-reqs and gpg keys for both the Docker and K8 repos
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

#Install the containerd package
sudo apt-get update
sudo apt-get install -y containerd.io

#Configure containerd to use the cgroup driver
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

#Restart containerd to apply and verify the install
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl status containerd
sleep 5

#Update apt package and install kubelet, kubeadm, kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sleep 5

#Lock kube* components so not updated during node updates
sudo apt-mark hold kubelet kubeadm kubectl

#Join worker nodes to the cluster
echo “Use the join token from the init output on the controlplane node. Ensure you use sudo”

#Install Cilium
#Install the Cilium CLI on the controlplane node
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

#Install Cilium on the controlplane node, replace kube-proxy then validate the install, then run a connectivity test
cilium install --version 1.18.6 --set kubeProxyReplacement=true
cilium status --wait
cilium connectivity test
sleep 5

#Remove kube-prox daemonset and validate truly gone from the cluster
kubectl delete daemonset kube-proxy -n kube-system
kubectl get pods -n kube-system | grep kube-proxy

#Enable Hubble, install the relay, validate status, validate flow API via query, then validate Cilium status is okay
cilium hubble enable
HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
HUBBLE_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
sleep 5
hubble status -P
hubble observe -P
sleep 5
cilium status --wait

#Enable the Hubble UI and then open it
echo "Open a second terminal to the controlplane node then run the below on the first terminal to open the UI"
cilium hubble enable --ui 
sleep 2
cilium hubble ui

#On the controlplane node label each worker and validated joined and ready
kubectl label node node01 node-role.kubernetes.io/worker=worker01
kubectl label node node02 node-role.kubernetes.io/worker=worker02
kubectl label node node03 node-role.kubernetes.io/worker=worker03
kubectl get nodes