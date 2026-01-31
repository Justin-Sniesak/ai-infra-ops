#!/bin/bash
#H100 GPU Provisioning

#Validate the manifests you will need are present on the control plane node
echo "Validate cudaTestPod.yaml, cudaTestPodChaos.yaml, h100-configmap.yaml and ztpCudaTestPod.yaml are present on the controlplane node"
sleep 15

#Install git on the controlplane node
sudo apt-get update && sudo apt-get install -y git

#Apply the h100 configmap
kubectl apply -f h100ConfigMap.yaml

#Install Helm and validate version
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
echo "Installing Helm...."
sleep 15
helm --version
echo "Helm successfully installed"

#Label all three nodes simulated gpu pool
kubectl label node node01 node02 node03 run.ai/simulated-gpu-node-pool=default
kubectl get nodes --show-labels | grep run.ai/simulated-gpu-node-pool

#Create the GPU namespace then validate
kubectl create ns gpu
kubectl get ns |grep gpu

#Install fake-gpu-operator chart in gpu namespace from GHCR
helm upgrade -i gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
-n gpu \
--set topology.nodePools.default.gpuCount=8 \
--set topology.nodePools.default.gpuProduct="H100" \
--set topology.nodePoolLabel=run.ai/simulated-gpu-node-pool
echo "Validating gpu-operator pods..."
sleep 120
kubectl get pods -n gpu
echo "Validating GPUs provisioned for each node - should be 8 for each for a total of 24"
kubectl describe nodes | grep -E "Name:|nvidia.com/gpu"

#Create the cudatestpod and validate 1/1 ready
kubectl create -f cudaTestPod.yaml
sleep 30
echo "Waiting for pod to be 1/1 ready...."
kubectl get pod -n gpu |grep cudatestpod
sleep 15
echo "Validate (1) GPU provisioned for pod"
kubectl describe pod cudatestpod -n gpu
sleep 15

#Apply chaos engineering pod manifest to force the cudatestpod to request 48 H100s. This will fail as only 24 are available
kubectl delete pod cudatestpod -n gpu
echo "Waiting for pod to terminate..."
sleep 30
kubectl get pod -n gpu |grep cudatestpod
sleep 15
kubectl create -f cudaTestPodChaos.yaml
echo "Waiting for chaos engineering pod to be 1/1 ready..."
sleep 30
kubectl describe pod cudatestpodchaos -n gpu
echo "Review the output - should see Insufficient nvidia.com/gpu. no claims to deallocate..."

#Delete the chaos engineering pod and recreate the pod requesting the correct amount of GPU
kubectl delete pod cudatestpodchaos -n gpu
echo "Waiting for pod to terminate..."
sleep 30
kubectl get pod -n gpu |grep cudatestpod
sleep 30
kubectl get pod -n gpu |grep cudatestpodchaos
kubectl create -f cudaTestPod.yaml
echo "Waiting for pod to be 1/1 ready..."
sleep 30
echo "Validate (1) GPU provisioned for pod"
kubectl get pod -n gpu |grep cudatestpod
sleep 30
kubectl describe pod cudatestpod -n gpu

#Exec into the cudatest pod and install iputils-ping tools, then ping 8.8.8.8 followed by east-west traffic validation in the Hubble UX
kubectl exec -it cudatestpod -n gpu -- /bin/bash -c "apt update && apt install -y iputils-ping && ping -c 12 8.8.8.8"
echo "Validate east-west traffic flows are egressing the pod in the Hubble UX in the gpu namespace"

#Apply the CNP to enforce zero-trust east-west traffic. Should see policy valid as "True"
kubectl create -f ztpCudaTestPod.yaml
kubectl get cnp -A

#Exec back into the cudatest pod then ping 8.8.8.8. East-west traffic validation in the Hubble UX should now show as blocked
kubectl exec -it cudatestpod -n gpu -- /bin/bash -c "ping -c 4 -w 20 8.8.8.8"
echo "H100 simulation completed"
echo "Validate east-west traffic flows are dropped in the Hubble UX in the gpu namespace"
