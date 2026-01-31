**ai-infra-ops**

This repository documents the design, implementation, and validation of a high-density AI infrastructure platform. It tracks the evolution from a baseline kubeadm cluster to a specialized GPU-orchestration environment utilizing Cilium for eBPF-based security and Run:ai for hardware simulation.

The goal of this project is to architect a platform capable of supporting mission-critical AI workloads while enforcing a Zero-Trust, identity-based networking model at the kernel level.

This is not a lab exercise or a reference architecture. It is an operational record of a specialized platform built, debugged, and validated to survive the "noise" of production AI operations. There are seven additional phases planned.

```
Repository Structure

ai-infra-ops/
├── 01_cluster_automation/
│   ├── screenshots/
│   ├── cluster_provisioning.sh
│   └── ops_log.md
│   └── README.md
├── 02_h100_cluster_simulation/
│   ├── manifests/
│   ├── screenshots/
│   ├── cluster_architectural_diagram.png
│   ├── h100_automation.sh
│   ├── ops_log.md
│   └── README.md
└── README.md
```

**High-Level Overview**

- **Cluster Orchestration:** 4-node Kubernetes cluster (v1.31) via kubeadm.

- **Hypervisor:** Ubuntu 24.04 nodes virtualized on OrbStack Desktop.

- **Networking:** Cilium CNI (Strict eBPF mode, kube-proxy replacement).

- **Hardware Simulation:** Run:ai Fake-GPU Operator (8x H100 simulation per node).

**Security Model:**

- Cilium Network Policies (CNP) for Zero-Trust egress/ingress.

- Explicit L7 gRPC/HTTP inspection for inference traffic.

- Automated blocking of unauthorized C2C (Command & Control) communication.

- Observability: Hubble UI + Hubble CLI for kernel-level flow auditing.

**Architecture:**

The architecture illustrates the control plane’s integration with virtualized GPU nodes and the eBPF data path. It maps the flow of inference requests through the Cilium service mesh, ensuring that every packet is authenticated and authorized before reaching simulated NVIDIA silicon.

Key concepts illustrated:

- Control plane to Kubelet communication (Port 10250) auditing.

- Namespace-scoped isolation for GPU workloads.

- Virtual GPU device-plugin registration and scheduling.

- Zero-Trust egress boundaries preventing data exfiltration.

**The Zero-Trust Mission:**

This platform operates on a "deny-by-default" posture:

- **Implicit Deny:** No workload-to-workload or workload-to-internet traffic is allowed unless explicitly defined.

- **Identity-Based:** Security is enforced via cryptographic workload identities, not ephemeral IP addresses.

- **Egress Hardening:** Specifically designed to block data exfiltration attempts and unauthorized external API calls.

- **Observed Validation:** Enforcement is verified through real-time packet drops in the eBPF datapath, captured via Hubble.

**Observability and Validation:**

Observability is the primary mechanism for validating the security posture:

- **Cilium-dbg:** Verified policy attachment and endpoint state at the node level.

- **Hubble Observe:** Captured and audited gRPC flows between simulated inference pods.

- **Stress Testing:** Validated scheduler failure states when over-requesting GPU resources.

- **Egress Auditing:** Confirmed policy-driven drops for unauthorized external traffic.

**Operational Logs:**

Detailed, chronological logs with visual "receipts" (screenshots) document the project's evolution. All phases have tested bash scripts which fully automate each phase:

- **Phase 1:** Cluster Creation - Cilium injection and L7 observability setup.

- **Phase 2:** GPU Simulation - H100 virtualization and Zero-Trust policy enforcement.

**Key Lessons Learned:**

- **GPU Scheduling Logic:** The Kubernetes scheduler requires precise node labeling to prevent "Pending" state loops in virtualized environments.

- **eBPF Efficiency:** Replacing kube-proxy with Cilium significantly reduces latency in high-concurrency gRPC inference workloads.

- **Failure as Signal:** Intentionally over-requesting resources is the only way to validate that the GPU operator and scheduler are communicating correctly.

- **Observability is Mandatory:** Without Hubble, Zero-Trust is just a theory. You must see the packet drop to confirm the policy is alive.
