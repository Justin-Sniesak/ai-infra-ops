#!/bin/bash
#Terminate script immediatly upon error
set -euo pipefail

#Sets the start of the script for runtime tracking
SECONDS=0

#Update packages and install jq, kubectl, wget, helm and curl if not already installed. Then, set env vars. Then, download the binaries, chmod them and move them for KWOK and kwokctl. Finally, validate each installed version.
sudo apt update && sudo apt install curl wget jq
KWOK_REPO=kubernetes-sigs/kwok
KWOK_LATEST_RELEASE=$(curl -s "https://api.github.com/repos/${KWOK_REPO}/releases/latest" | jq -r '.tag_name')
wget -O kwokctl -c "https://github.com/${KWOK_REPO}/releases/download/${KWOK_LATEST_RELEASE}/kwokctl-linux-arm64"
chmod +x kwokctl
sudo mv kwokctl /usr/local/bin/kwokctl
wget -O kwok -c "https://github.com/${KWOK_REPO}/releases/download/${KWOK_LATEST_RELEASE}/kwok-linux-arm64"
chmod +x kwok
sudo mv kwok /usr/local/bin/kwok
wget -O kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
wget -O get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

# Verify installation
kubectl version --client
kwokctl --version
kwok --version

#Tune the guest by adjusting multiple paramaters needed to accomodate scale of the simulation. None of these settings will persist post reboot
ulimit -n 1048576 #Temp increase file descriptor limits
sudo sysctl -w net.ipv4.ip_local_port_range="1024 65535" || true #Temp increase ephimeral port range (default is 28K)
sudo sysctl -w net.core.somaxconn=4096 || true #Kernal to app queue. Default is 4096, this hardcodes this int temporarily - defines the max number of concurrent connections that are accepted
sudo sysctl -w fs.inotify.max_user_watches=524288 || true #inotify watch - anytime change is made to a file Ubuntu has to monitor it (Default is 8192). This allows the OS to monitor for all changes due to scale (2000 nodes/20000 pods)

#Create cluster, provides context command. prints cluster list to the terminal
#DRA is required for advanced GPU simulations as of K8 1.35.0
#Default ETCD size is 2Gi. This is not sufficient for this sim. Set to 6Gi
#Max requests increases the amount of read/write requests that may be handled at one time
KWOK_KUBE_VERSION=v1.35.0 kwokctl create cluster \
    --name seattle-lab-k8s-hyperscalegpucluster \
    --kube-feature-gates=DynamicResourceAllocation=true \
    --extra-args="etcd=quota-backend-bytes=6442450944" \
    --extra-args="kube-apiserver=max-requests-inflight=4000" \
    --extra-args="kube-apiserver=max-mutating-requests-inflight=2000"

echo "Cluster created successfully. To switch context use 'kubectl config use-context seattle-lab-k8s-hyperscalegpucluster'"
kwokctl get clusters

#Validate all bash scripts and node manifests are present on the control plane node.
echo "Validate you have moved the following to your control plane node:"
echo "Node Manifests: kwokNodesA30.yaml, kwokNodesA100.yaml, kwokNodesB100.yaml, kwokNodesB200.yaml, kwokNodesB580.yaml, kwokNodesCrescentIsland.yaml, kwokNodesFalconShores.yaml,kwokNodesGB200.yaml, kwokNodesH100.yaml, kwokNodesH200.yaml, kwokNodesJaguarShores.yaml, kwokNodesL4.yaml, kwokNodesMax1550.yaml, kwokNodesmi300a.yaml, kwokNodesmi300x.yaml, kwokNodesmi325x.yaml, kwokNodesmi350x.yaml, kwokNodesmi355x.yaml, kwokNodesT4.yaml, kwokNodesV100.yaml."
echo "ForLoop scripts: a30Nodes.sh, a100Nodes.sh, b100Nodes.sh, b200Nodes.sh, b580Nodes.sh, crescentIslandNodes.sh, falconShoresNodes.sh, gb200Nodes.sh, h100Nodes.sh, h200Nodes.sh, jaguarShoresNodes.sh, l4Nodes.sh, max1550Nodes.sh, mi300aNodes.sh, mi300xNodes.sh, mi325xNodes.sh, mi350xNodes.sh, mi355xNodes.sh, t4Nodes.sh, v100Nodes.sh."
echo "Deployment Manifests: a30Deployment.yaml, a100Deployment.yaml, b100Deployment.yaml, b200Deployment.yaml, b580Deployment.yaml, crescentIslandDeployment.yaml, falconShoresDeployment.yaml, gb200Deployment.yaml, h100Deployment.yaml, h200Deployment.yaml, jaguarShoresDeployment.yaml, l4Deployment.yaml, max1550Deployment.yaml, mi300aDeployment.yaml, mi300xDeployment.yaml, mi325xDeployment.yaml, mi350xDeployment.yaml, mi355xDeployment.yaml, t4Deployment.yaml, v100Deployment.yaml."
sleep 5

#Switch context to cluster then create directories for all node and pod outputs
kubectl config use-context kwok-seattle-lab-k8s-hyperscalegpucluster
mkdir hyperscale_output_nodes && mkdir hyperscale_output_deployments
chmod 755 -R hyperscale_output_nodes && chmod 755 -R hyperscale_output_deployments
echo "hyperscale_output_nodes and hyperscale_output_deployments directories created..."

#Switch context between clusters and use the provided forloops to provision the nodes. Each GPU is assigned 100 nodes, so the total will increment by 100 with each loop
echo "Creating gb200 nodes..."
chmod 755 gb200Nodes.sh
./gb200Nodes.sh > hyperscale_output_nodes/gb200Nodes.txt
echo "Here are your ready gb200 nodes. Should see 100..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating b100 nodes..."
chmod 755 b100Nodes.sh
./b100Nodes.sh > hyperscale_output_nodes/b100Nodes.txt
echo "Here are your ready b100 nodes. Should see 200..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating b200 nodes..."
chmod 755 b200Nodes.sh
./b200Nodes.sh > hyperscale_output_nodes/b200Nodes.txt
echo "Here are your ready b200 nodes. Should see 300..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating h100 nodes..."
chmod 755 h100Nodes.sh
./h100Nodes.sh > hyperscale_output_nodes/h100Nodes.txt
echo "Here are your ready h100 nodes. Should see 400..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating h200 nodes..."
chmod 755 h200Nodes.sh
./h200Nodes.sh > hyperscale_output_nodes/h200Nodes.txt
echo "Here are your ready h200 nodes. Should see 500..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating a30 nodes..."
chmod 755 a30Nodes.sh
./a30Nodes.sh > hyperscale_output_nodes/a30Nodes.txt
echo "Here are your ready a30 nodes. Should see 600..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating a100 nodes..."
chmod 755 a100Nodes.sh
./a100Nodes.sh > hyperscale_output_nodes/a100Nodes.txt
echo "Here are your ready a100 nodes. Should see 700..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating v100 nodes..."
chmod 755 v100Nodes.sh
./v100Nodes.sh > hyperscale_output_nodes/v100Nodes.txt
echo "Here are your ready v100 nodes. Should see 800..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating l4 nodes..."
chmod 755 l4Nodes.sh
./l4Nodes.sh > hyperscale_output_nodes/l4Nodes.txt
echo "Here are your ready l4 nodes. Should see 900..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating t4 nodes..."
chmod 755 t4Nodes.sh
./t4Nodes.sh > hyperscale_output_nodes/t4Nodes.txt
echo "Here are your ready t4 nodes. Should see 1000..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating mi355x nodes..."
chmod 755 mi355xNodes.sh
./mi355xNodes.sh > hyperscale_output_nodes/mi355xNodes.txt
echo "Here are your ready mi355x nodes. Should see 1100..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating mi350x nodes..."
chmod 755 mi350xNodes.sh
./mi350xNodes.sh > hyperscale_output_nodes/mi350xNodes.txt
echo "Here are your ready mi350x nodes. Should see 1200..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating mi325x nodes..."
chmod 755 mi325xNodes.sh
./mi325xNodes.sh > hyperscale_output_nodes/mi325xNodes.txt
echo "Here are your ready mi325x nodes. Should see 1300..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating mi300x nodes..."
chmod 755 mi300xNodes.sh
./mi300xNodes.sh > hyperscale_output_nodes/mi300xNodes.txt
echo "Here are your ready mi300x nodes. Should see 1400..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating mi300a nodes..."
chmod 755 mi300aNodes.sh
./mi300aNodes.sh > hyperscale_output_nodes/mi300aNodes.txt
echo "Here are your ready mi300a nodes. Should see 1500..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating jaguarshores nodes..."
chmod 755 jaguarShoresNodes.sh
./jaguarShoresNodes.sh > hyperscale_output_nodes/jaguarShoresNodes.txt
echo "Here are your ready jaguarshores nodes. Should see 1600..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating falconshores nodes..."
chmod 755 falconShoresNodes.sh
./falconShoresNodes.sh > hyperscale_output_nodes/falconShoresNodes.txt
echo "Here are your ready falconshores nodes. Should see 1700..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating crescentisland nodes..."
chmod 755 crescentIslandNodes.sh
./crescentIslandNodes.sh > hyperscale_output_nodes/crescentIslandNodes.txt
echo "Here are your ready crescentisland nodes. Should see 1800..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating max1550 nodes..."
chmod 755 max1550Nodes.sh
./max1550Nodes.sh > hyperscale_output_nodes/max1550Nodes.txt
echo "Here are your ready max1550 nodes. Should see 1900..."
kubectl get nodes --no-headers | wc -l
sleep 10
echo "Creating b580 nodes..."
chmod 755 b580Nodes.sh
./b580Nodes.sh > hyperscale_output_nodes/b580Nodes.txt
echo "Here are your ready b580 nodes. Should see 2000..."
kubectl get nodes --no-headers | wc -l
sleep 10

#Install the fake-gpu-operator on each cluster. Wait for all GPU-Operator pods to become ready. Then show GPU count and type per node (10).
kubectl create ns gb200
kubectl get ns |grep gb200
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
--version 0.0.72 \
-n gb200 \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="gb200" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n gb200 --timeout=30s
kubectl wait --for=condition=Ready pods --all -n gb200 --timeout=30s
kubectl get pods -n gb200
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/gb200NodeGPUCount.txt for details"
kubectl get nodes -l gpu=gb200 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/gb200NodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns b100
kubectl get ns |grep b100
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n b100 \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="b100" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n b100 --timeout=30s
kubectl wait --for=condition=Ready pods --all -n b100 --timeout=30s
kubectl get pods -n b100
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/b100NodeGPUCount.txt for details"
kubectl get nodes -l gpu=b100 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/b100NodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns b200
kubectl config set-context --current --namespace=b200
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n b200 \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="b200" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n b200 --timeout=30s
kubectl wait --for=condition=Ready pods --all -n b200 --timeout=30s
kubectl get pods -n b200
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/b200NodeGPUCount.txt for details"
kubectl get nodes -l gpu=b200 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/b200NodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns h100
kubectl config set-context --current --namespace=h100
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n h100 \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="h100" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n h100 --timeout=30s
kubectl wait --for=condition=Ready pods --all -n h100 --timeout=30s
kubectl get pods -n h100
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/h100NodeGPUCount.txt for details"
kubectl get nodes -l gpu=h100 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/h100NodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns h200
kubectl config set-context --current --namespace=h200
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n h200 \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="h200" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n h200 --timeout=30s
kubectl wait --for=condition=Ready pods --all -n h200 --timeout=30s
kubectl get pods -n h200
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/h200NodeGPUCount.txt for details"
kubectl get nodes -l gpu=h200 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/h200NodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns a30
kubectl config set-context --current --namespace=a30
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n a30 \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="a30" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n a30 --timeout=30s
kubectl wait --for=condition=Ready pods --all -n a30 --timeout=30s
kubectl get pods -n a30
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/a30NodeGPUCount.txt for details"
kubectl get nodes -l gpu=a30 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/a30NodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns a100
kubectl config set-context --current --namespace=a100
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n a100 \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="a100" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n a100 --timeout=30s
kubectl wait --for=condition=Ready pods --all -n a100 --timeout=30s
kubectl get pods -n a100
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/a100NodeGPUCount.txt for details"
kubectl get nodes -l gpu=a100 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/a100NodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns v100
kubectl config set-context --current --namespace=v100
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n v100 \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="v100" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n v100 --timeout=30s
kubectl wait --for=condition=Ready pods --all -n v100 --timeout=30s
kubectl get pods -n v100
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/v100NodeGPUCount.txt for details"
kubectl get nodes -l gpu=v100 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/v100NodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns l4
kubectl config set-context --current --namespace=l4
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n l4 \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="l4" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n l4 --timeout=30s
kubectl wait --for=condition=Ready pods --all -n l4 --timeout=30s
kubectl get pods -n l4
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/l4NodeGPUCount.txt for details"
kubectl get nodes -l gpu=l4 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/l4NodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns t4
kubectl config set-context --current --namespace=t4
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n t4 \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="t4" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n t4 --timeout=30s
kubectl wait --for=condition=Ready pods --all -n t4 --timeout=30s
kubectl get pods -n t4
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/t4NodeGPUCount.txt for details"
kubectl get nodes -l gpu=t4 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/t4NodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns mi355x
kubectl config set-context --current --namespace=mi355x
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n mi355x \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="mi355x" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n mi355x --timeout=30s
kubectl wait --for=condition=Ready pods --all -n mi355x --timeout=30s
kubectl get pods -n mi355x
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/mi355xNodeGPUCount.txt for details"
kubectl get nodes -l gpu=mi355x -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.amd\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/mi355xNodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns mi350x
kubectl config set-context --current --namespace=mi350x
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n mi350x \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="mi350x" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n mi350x --timeout=30s
kubectl wait --for=condition=Ready pods --all -n mi350x --timeout=30s
kubectl get pods -n mi350x
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/mi350xNodeGPUCount.txt for details"
kubectl get nodes -l gpu=mi350x -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.amd\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/mi350xNodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns mi325x
kubectl config set-context --current --namespace=mi325x
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n mi325x \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="mi325x" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n mi325x --timeout=30s
kubectl wait --for=condition=Ready pods --all -n mi325x --timeout=30s
kubectl get pods -n mi325x
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/mi325xNodeGPUCount.txt for details"
kubectl get nodes -l gpu=mi325x -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.amd\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/mi325xNodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns mi300x
kubectl config set-context --current --namespace=mi300x
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n mi300x \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="mi300x" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n mi300x --timeout=30s
kubectl wait --for=condition=Ready pods --all -n mi300x --timeout=30s
kubectl get pods -n mi300x
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/mi300xNodeGPUCount.txt for details"
kubectl get nodes -l gpu=mi300x -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.amd\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/mi300xNodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns mi300a
kubectl config set-context --current --namespace=mi300a
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n mi300a \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="mi300a" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n mi300a --timeout=30s
kubectl wait --for=condition=Ready pods --all -n mi300a --timeout=30s
kubectl get pods -n mi300a
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/mi300aNodeGPUCount.txt for details"
kubectl get nodes -l gpu=mi300a -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.amd\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/mi300aNodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns jaguarshores
kubectl config set-context --current --namespace=jaguarshores
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n jaguarshores \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="jaguarshores" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n jaguarshores --timeout=30s
kubectl wait --for=condition=Ready pods --all -n jaguarshores --timeout=30s
kubectl get pods -n jaguarshores
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/jaguarShoresNodeGPUCount.txt for details"
kubectl get nodes -l gpu=jaguarshores -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.intel\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/jaguarShoresNodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns falconshores
kubectl config set-context --current --namespace=falconshores
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n falconshores \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="falconshores" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n falconshores --timeout=30s
kubectl wait --for=condition=Ready pods --all -n falconshores --timeout=30s
kubectl get pods -n falconshores
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/falconShoresNodeGPUCount.txt for details"
kubectl get nodes -l gpu=falconshores -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.intel\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/falconShoresNodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns crescentisland
kubectl config set-context --current --namespace=crescentisland
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n crescentisland \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="crescentisland" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n crescentisland --timeout=30s
kubectl wait --for=condition=Ready pods --all -n crescentisland --timeout=30s
kubectl get pods -n crescentisland
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/crescentIslandNodeGPUCount.txt for details"
kubectl get nodes -l gpu=crescentisland -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.intel\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/crescentIslandNodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns max1550
kubectl config set-context --current --namespace=max1550
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n max1550 \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="max1550" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n max1550 --timeout=30s
kubectl wait --for=condition=Ready pods --all -n max1550 --timeout=30s
kubectl get pods -n max1550
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/max1550NodeGPUCount.txt for details"
kubectl get nodes -l gpu=max1550 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.intel\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/max1550NodeGPUCount.txt
sleep 10
kubectl delete clusterrole compute-domain-controller-role fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete clusterrolebinding compute-domain-controller-role-binding fake-kwok-gpu-device-plugin fake-device-plugin topology-server mig-faker fake-status-exporter fake-status-updater --ignore-not-found
kubectl delete deviceclass compute-domain-default-channel.nvidia.com compute-domain-default-channel.nvidia.com --ignore-not-found
kubectl delete runtimeclass nvidia --ignore-not-found
kubectl create ns b580
kubectl config set-context --current --namespace=b580
helm install gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n b580 \
--set topology.nodePools.default.gpuCount=10 \
--set topology.nodePools.default.gpuProduct="b580" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods are ready..."
kubectl wait --for=condition=Available deployment/gpu-operator -n b580 --timeout=30s
kubectl wait --for=condition=Ready pods --all -n b580 --timeout=30s
kubectl get pods -n b580
echo "Validating GPUs provisioned for each node - should be 10 for each for a total of 1000. See hyperscale_output_nodes/b580NodeGPUCount.txt for details"
kubectl get nodes -l gpu=b580 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.status.allocatable.intel\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_nodes/b580NodeGPUCount.txt

#Apply the deployment manifest and validate pods are showing as ready
kubectl create -f gb200Deployment.yaml --namespace=gb200
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/gb200 -n gb200 --timeout=300s
kubectl wait --for=condition=Ready pods --all -n gb200 --timeout=300s > hyperscale_output_deployments/gb200Deployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/gb200PodsGPUCount.txt"
kubectl get pods -l gpu=gb200 -n gb200 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/gb200PodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f b100Deployment.yaml --namespace=b100
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/b100 -n b100 --timeout=300s
kubectl wait --for=condition=Ready pods --all -n b100 --timeout=300s > hyperscale_output_deployments/b100Deployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/b100PodsGPUCount.txt"
kubectl get pods -l gpu=b100 -n b100 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/b100PodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f b200Deployment.yaml --namespace=b200
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/b200 -n b200 --timeout=300s
kubectl wait --for=condition=Ready pods --all -n b200 --timeout=300s > hyperscale_output_deployments/b200Deployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/b200PodsGPUCount.txt"
kubectl get pods -l gpu=b200 -n b200 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/b200PodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f h100Deployment.yaml --namespace=h100
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/h100 -n h100 --timeout=300s
kubectl wait --for=condition=Ready pods --all -n h100 --timeout=300s > hyperscale_output_deployments/h100Deployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/h100PodsGPUCount.txt"
kubectl get pods -l gpu=h100 -n h100 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/h100PodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl apply -f h200Deployment.yaml --namespace=h200
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/h200 -n h200 --timeout=300s
kubectl wait --for=condition=Ready pods --all -n h200 --timeout=300s > hyperscale_output_deployments/h200Deployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/h200PodsGPUCount.txt"
kubectl get pods -l gpu=h200 -n h200 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/h200PodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f a30Deployment.yaml --namespace=a30
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/a30 -n a30 --timeout=300s
kubectl wait --for=condition=Ready pods --all -n a30 --timeout=300s > hyperscale_output_deployments/a30Deployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/a30PodsGPUCount.txt"
kubectl get pods -l gpu=a30 -n a30 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/a30PodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f a100Deployment.yaml --namespace=a100
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/a100 -n a100 --timeout=300s
kubectl wait --for=condition=Ready pods --all -n a100 --timeout=300s > hyperscale_output_deployments/a100Deployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/a100PodsGPUCount.txt"
kubectl get pods -l gpu=a100 -n a100 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/a100PodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f v100Deployment.yaml --namespace=v100
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/v100 -n v100 --timeout=300s
kubectl wait --for=condition=Ready pods --all -n v100 --timeout=300s > hyperscale_output_deployments/v100Deployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/v100PodsGPUCount.txt"
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl get pods -l gpu=v100 -n v100 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/v100PodsGPUCount.txt
kubectl create -f l4Deployment.yaml --namespace=l4
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/l4 -n l4 --timeout=300s
kubectl wait --for=condition=Ready pods --all -n l4 -timeout=300s > hyperscale_output_deployments/l4Deployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/l4PodsGPUCount.txt"
kubectl get pods -l gpu=l4 -n l4 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/l4PodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f t4Deployment.yaml --namespace=t4
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/t4 -n t4 --timeout=300s
kubectl wait --for=condition=Ready pods --all -n t4 --timeout=300s > hyperscale_output_deployments/t4Deployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/t4PodsGPUCount.txt"
kubectl get pods -l gpu=t4 -n t4 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.nvidia\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/t4PodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f mi355xDeployment.yaml --namespace=mi355x
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/mi355x -n mi355x --timeout=300s
kubectl wait --for=condition=Ready pods --all -n mi355x --timeout=300s > hyperscale_output_deployments/mi355xDeployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/mi355xPodsGPUCount.txt"
kubectl get pods -l gpu=mi355x -n mi355x -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.amd\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/mi355xPodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f mi350xDeployment.yaml --namespace=mi350x
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/mi350x -n mi350x --timeout=300s
kubectl wait --for=condition=Ready pods --all -n mi350x --timeout=300s > hyperscale_output_deployments/mi350xDeployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/mi350xPodsGPUCount.txt"
kubectl get pods -l gpu=mi350x -n mi350x -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.amd\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/mi350xPodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f mi325xDeployment.yaml --namespace=mi325x
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/mi325x -n mi325x --timeout=300s
kubectl wait --for=condition=Ready pods --all -n mi325x --timeout=300s > hyperscale_output_deployments/mi325xDeployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/mi325xPodsGPUCount.txt"
kubectl get pods -l gpu=mi325x -n mi325x -o custom-columns="NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.amd\.com/gpu,GPU_TYPE:.metadata.labels.gpu" > hyperscale_output_deployments/mi325xPodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f mi300xDeployment.yaml --namespace=mi300x
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/mi300x -n mi300x --timeout=300s
kubectl wait --for=condition=Ready pods --all -n mi300x --timeout=300s > hyperscale_output_deployments/mi300xDeployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/mi300xPodsGPUCount.txt"
kubectl get pods -l gpu=mi300x -n mi300x -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.amd\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/mi300xPodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f mi300aDeployment.yaml --namespace=mi300a
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/mi300a -n mi300a --timeout=300s
kubectl wait --for=condition=Ready pods --all -n mi300a --timeout=300s > hyperscale_output_deployments/mi300aDeployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/mi300aPodsGPUCount.txt"
kubectl get pods -l gpu=mi300a -n mi300a -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.amd\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/mi300aPodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f jaguarShoresDeployment.yaml --namespace=jaguarshores
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/jaguarshores -n jaguarshores --timeout=300s
kubectl wait --for=condition=Ready pods --all -n jaguarshores --timeout=300s > hyperscale_output_deployments/jaguarShoresDeployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/jaguarShoresPodsGPUCount.txt"
kubectl get pods -l gpu=jaguarshores -n jaguarshores -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.intel\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/jaguarShoresPodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f falconShoresDeployment.yaml --namespace=falconshores
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/falconshores -n falconshores --timeout=300s
kubectl wait --for=condition=Ready pods --all -n falconshores --timeout=300s > hyperscale_output_deployments/falconShoresDeployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/falconShoresPodsGPUCount.txt"
kubectl get pods -l gpu=falconshores -n falconshores -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.intel\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/falconShoresPodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f crescentIslandDeployment.yaml --namespace=crescentisland
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/crescentisland -n crescentisland --timeout=300s
kubectl wait --for=condition=Ready pods --all -n crescentisland --timeout=300s > hyperscale_output_deployments/crescentIslandDeployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/crescentIslandPodsGPUCount.txt"
kubectl get pods -l gpu=crescentisland -n crescentisland -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.intel\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/crescentIslandPodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f max1550Deployment.yaml --namespace=max1550
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/max1550 -n max1550 --timeout=300s
kubectl wait --for=condition=Ready pods --all -n max1550 --timeout=300s > hyperscale_output_deployments/max1550Deployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/max1550PodsGPUCount.txt"
kubectl get pods -l gpu=max1550 -n max1550 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.intel\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/max1550PodsGPUCount.txt
echo "Sleeping 60 seconds to allow time for ETCD commits to finish then move to the next cluster..."
sleep 60
kubectl create -f b580Deployment.yaml --namespace=b580
echo "Waiting for pods to be 1/1 ready...."
kubectl wait --for=condition=Available deployment/b580 -n b580 --timeout=300s
kubectl wait --for=condition=Ready pods --all -n b580 --timeout=300s > hyperscale_output_deployments/b580Deployment.txt
echo "Validate (1) GPU provisioned for each pod. Check created txt files for details. Path is hyperscale_output_deployments/b580PodsGPUCount.txt"
kubectl get pods -l gpu=b580 -n b580 -o custom-columns='NAME:.metadata.name,GPU_COUNT:.spec.containers[*].resources.limits.intel\.com/gpu,GPU_TYPE:.metadata.labels.gpu' > hyperscale_output_deployments/b580PodsGPUCount.txt

#ETCD utilization validation
echo "validate ETCD database utilization is under 6Gi"
kwokctl --name seattle-lab-k8s-hyperscalegpucluster etcdctl endpoint status --write-out=table
sleep 5

#End of Script
HOURS=$((SECONDS / 3600))
MINS=$(( (SECONDS % 3600) / 60 ))
printf "Total runtime of script: %02d hours, %02d minutes\n" "$HOURS" "$MINS"
echo "Script completed - all clusters, nodes and deployments configured and available."
