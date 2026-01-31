## Phase 1 - Cluster Creation
**Summary:** Automated provisioning of four node cluster, cilium, hubble

- 2026-01-30 Create and validate namespace on controlplane node.
  ![h1](../02_h100_cluster_simulation/screenshots/h1.jpg)
- 2026-01-30 Label each node and confirm labels have been applied.
  ![h2](../02_h100_cluster_simulation/screenshots/h2.jpg)
- 2026-01-30 Install Helm and validate version.
  ![h3](../02_h100_cluster_simulation/screenshots/h3.jpg)
- 2026-01-30 Install fake-gpu-operator chart in gpu namespace from GHCR.
  ![h4](../02_h100_cluster_simulation/screenshots/h4.jpg)
- 2026-01-30 Describe cudatestpod, validate image pulled correctly.
  ![h5](../02_h100_cluster_simulation/screenshots/h5.jpg)
- 2026-01-30 Validate H100 pod is failing via describe due to requesting more GPUs then the cluster has provisioned.
  ![h6](../02_h100_cluster_simulation/screenshots/h5.jpg)
- 2026-01-30 Validate Cilium Network Zero Trust Policy applied and is true.
  ![h7](../02_h100_cluster_simulation/screenshots/h7.jpg)
- 2026-01-30 Validate Zero Trust Policy enforcement is dropping egress traffic preventing both data exfiltration as well as external communication with a C2C server.
  ![h8](../02_h100_cluster_simulation/screenshots/h8.jpg)