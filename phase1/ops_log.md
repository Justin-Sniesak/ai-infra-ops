## Phase 1 - Cluster Creation
**Summary:** Automated provisioning of four node cluster, cilium, hubble

- 2026-01-30 Label all worker nodes with role then validate all nodes in the cluster are joined and ready.
  ![cl1](../screenshots/cl1.jpg)
- 2026-01-30 Install Cilium - Run and validate tests validate status
  ![cl1](phase1/screenshots/cl2.jpg)
- 2026-01-30 Validate Hubble install and UX readiness.
  ![cl1](phase1/screenshots/cl3.jpg)
- 2026-01-30 Validate UX comes up and is accessible once port forwarding is enabled from the controlplane node.
  ![cl1](phase1/screenshots/cl4.jpg)
- 2026-01-30 Validate traffic flows and api query-availability.
  ![cl1](phase1/screenshots/cl5.jpg)
- 2026-01-30 Validate can trace east west traffic in UX.
  ![cl1](phase1/screenshots/cl6.jpg)
