**ai-infra-ops**

This repository documents the design, implementation, and validation of a high-density AI infrastructure platform. It tracks the evolution from a baseline kubeadm cluster to a hyperscale GPU-orchestration environment utilizing Cilium for eBPF-based security, Run:ai for hardware simulation, and KWOK for hyperscale control-plane testing.

This is not a lab exercise or a reference architecture. It is an operational record of a specialized platform built, debugged, and validated to survive the "noise" of production AI operations.

```
ai-infra-ops/
├── 01_cluster_automation/
│   ├── screenshots/
│   ├── cluster_provisioning.sh
│   ├── ops_log.md
│   └── README.md
├── 02_h100_cluster_simulation/
│   ├── manifests/
│   ├── screenshots/
│   ├── cluster_architectural_diagram.png
│   ├── h100_automation.sh
│   ├── ops_log.md
│   └── README.md
├── 03_hyperscale_GPU/
│   ├── buildscript_removescript_archdiagram/
│   │   ├── hyperscaleautomation.sh         # 700+ line hydration engine
│   │   ├── hyperscaleGPUFleet.drawio.png   # Phase 3 Architecture
│   │   └── kwokRemove.sh
│   ├── hyperscale_output_deployments/       # Pod-level validation receipts (20 types)
│   │   ├── [vendor]Deployment.txt
│   │   └── [vendor]PodsGPUCount.txt
│   ├── hyperscale_output_nodes/             # Node-level inventory receipts (20 types)
│   │   ├── [vendor]Nodes.txt
│   │   └── [vendor]NodeGPUCount.txt
│   ├── manifests/
│   │   ├── deployments/                    # 20 Hardware-specific Deployment YAMLs
│   │   ├── nodes/                          # 20 KWOK Node manifests (NVIDIA, AMD, Intel)
│   │   └── scripts/                        # Supporting for-loop bash orchestration
├── LICENSE.md
└── README.md
```

**High-Level Overview**

- **Cluster Orchestration:** 4-node Kubernetes cluster (v1.31) via kubeadm.

- **Hypervisor:** Ubuntu 24.04 nodes virtualized on OrbStack Desktop.

- **Networking:** Cilium CNI (Strict eBPF mode, kube-proxy replacement).

**Hardware Simulation:** Run:ai Fake-GPU Operator & KWOK for hyperscale modeling.

**The Phases**

- **Phase 1:** Cluster Creation – Baseline provisioning with Cilium injection and L7 observability.

- **Phase 2:** GPU Simulation – H100 virtualization and Zero-Trust egress policy enforcement.

- **Phase 3:** Hyperscale Simulation – Hydration of 2,000 nodes and 20,000 pods on a single control plane.

**Phase 3: Hyperscale Engineering**

Phase 3 represents the "stress test" of the platform, pushing the Kubernetes control plane to its theoretical saturation points.

**Key Achievements:**

- **The Hydration Engine:** A 700+ line idempotent bash script that automates the lifecycle of a heterogeneous GPU fleet.

- **Kernel Hardening:** Tuned the guest OS to handle massive I/O by pushing to 1M+ file descriptors and 500k+ inotify watches.

- **Etcd Optimization:** Refactored the etcd quota-backend to 6Gi and tuned API server mutation limits to survive the hydration of 20,000 concurrent objects.

- **Multi-Vendor Orchestration:** Managed 20 distinct GPU architectures across NVIDIA, AMD, and Intel, utilizing surgical logic to clear ClusterRole and DeviceClass collisions.

**The Zero-Trust Mission**

This platform operates on a "deny-by-default" posture:

- **Identity-Based:** Security is enforced via cryptographic workload identities, not ephemeral IP addresses.

- **Egress Hardening:** Specifically designed to block data exfiltration attempts and unauthorized external API calls (C2C).

- **Observed Validation:** Enforcement is verified through real-time packet drops in the eBPF datapath, captured via Hubble.

**Key Lessons Learned**

- **Abstractions Evaporate at Scale:** Kubernetes is stable until you hit the point where the Linux kernel and etcd state store start fighting for resources. Scaling to 2k nodes is a kernel-tuning exercise, not a YAML exercise.

- **eBPF Efficiency:** Replacing kube-proxy with Cilium significantly reduces latency and CPU jitter in high-concurrency gRPC inference workloads.

- **Observability is Mandatory:** Without Hubble, Zero-Trust is just a theory. You must see the packet drop to confirm the policy is alive.

---
<u>**Justin D. Sniesak**</u>  
*Senior Site Reliability Engineer | Platform Architect*
