kubectl delete ns gb200 b100 l4 t4 b200 h100 h200 a30 a100 v100 jaguarshores falconshores crescentisland max1550 b580 mi300a mi300x mi325x mi350x mi355x
rm -R hyperscale_output_deployments hyperscale_output_nodes
rm -rf ~/.kwok/clusters/kwok-seattle-lab-k8s-hyperscalegpucluster
kwokctl delete cluster --name seattle-lab-k8s-hyperscalegpucluster
