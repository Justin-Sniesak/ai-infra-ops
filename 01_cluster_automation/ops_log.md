## Phase 1 - Cluster Creation

- 01-30-2026 Labeled worker nodes with targeted roles; verified all nodes in Ready state via kubectl get nodes.
  ![cl1](../01_cluster_automation/screenshots/cl1.jpg)
- 01-30-2026 Injected Cilium CNI; executed connectivity suite to validate cross-node pod communication.
  ![cl1](../01_cluster_automation/screenshots/cl2.jpg)
- 01-30-2026 Initialized Hubble; verified observability agent health and API responsiveness.
  ![cl1](../01_cluster_automation/screenshots/cl3.jpg)
- 01-30-2026 Established port-forwarding from control plane; validated Hubble UX accessibility via local host.
  ![cl1](../01_cluster_automation/screenshots/cl4.jpg)
- 01-30-2026 Verified gRPC/HTTP traffic flow and validated API query-availability for external monitoring.
  ![cl1](../01_cluster_automation/screenshots/cl5.jpg)
- 01-30-2026 Traced and audited east-west traffic in Hubble UX; confirmed identity-based policy enforcement.
  ![cl1](../01_cluster_automation/screenshots/cl6.jpg)

**Summary:** Automated provisioning of 4-node cluster with Cilium/Hubble; verified zero-loss L7 observability for east-west traffic.