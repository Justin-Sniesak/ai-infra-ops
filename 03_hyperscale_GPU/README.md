### Hyperscale Heterogeneous GPU Simulation Engine

This repository contains an automated orchestration engine designed to simulate a Tier-1 hyperscale Kubernetes environment. It provisions 2,000 nodes and 20,000 pods across 20 distinct GPU architectures from NVIDIA, AMD, and Intel.

The project demonstrates advanced SRE capabilities in platform architecture, custom kernel tuning, and multi-vendor infrastructure-as-code (IaC).

Please note - the primary script for this repo intentionally does not follow WET and DRY to improve readibility. Forloops are used extensivly when applicable.

**🚀 Architectural Overview**

The simulation utilizes KWOK (Kubernetes Without Kubelet) and a customized Fake GPU Operator to mimic hyperscale workloads on a single control plane.

**Core Components**

- **Capacity:** 2,000 Nodes / 20,000 Pods.

- **Multi-Vendor Fleet:** Integrated simulation for NVIDIA (H100, B200, etc.), AMD (MI300 series), and Intel (Falcon Shores, Jaguar Shores).

- **Advanced Networking:** Custom sysctl tuning for high-concurrency connection handling.

- **State Optimization:** Optimized etcd backend with expanded 6Gi quotas to support massive object hydration without API server collapse.

**📁 Repository Structure**

- **buildscript_removescript_archdiagram/:** Contains the primary orchestration engine (hyperscaleautomation.sh), the teardown script, and visual architecture.

- **hyperscale_output_deployments/:** Validation receipts for the 20,000-pod deployment, confirming 1:1 GPU mapping.

- **hyperscale_output_nodes/:** Automated inventory receipts for every node model, validating labels and resource allocation.

- **manifests/:** Source YAML for heterogenous node pools and multi-vendor deployments.

- **scripts/:** Modular logic loops used by the automation engine to hydrate specific hardware tiers.

**🛠️ Technical Implementation Detail**

**Guest OS Tuning**

To support the scale of 2,000 nodes on a local instance, the following parameters are dynamically tuned:

- **File Descriptors:** ulimit -n 1048576

- **Ephemeral Ports:** net.ipv4.ip_local_port_range expanded to 64k.

- **Kernel Queue:** net.core.somaxconn tuned to 4096 for high-load API requests.

- **Inotify Watches:** fs.inotify.max_user_watches increased to 524,288 for real-time file monitoring.

**Automation Logic**

The hyperscaleautomation.sh script handles the full lifecycle:

- **Dependency Injection:** Installs KWOK, Helm, and Kubectl binaries.

- **Cluster Orchestration:** Provisions the cluster with Dynamic Resource Allocation (DRA) enabled.

- **Tiered Hydration:** Provisions nodes in 100-node increments using hardware-specific manifests.

- **Operator Isolation:** Manages the lifecycle of GPU operators, including ClusterRole cleanup between vendor transitions to prevent state corruption.

- **Audit Trail:** Generates isolated receipts for every component using specific JSONPath queries for nvidia.com, amd.com, and intel.com resources.

**📊 Inventory Validation**

The simulation partitions the 2,000-node fleet into 20 models (100 nodes each). Validation can be reviewed in the hyperscale_output_nodes/ directory.

**Vendor Models Simulated**

- **NVIDIA** GB200, B200, B100, H200, H100, A100, A30, V100, L4, T4

- **AMD** MI355X, MI350X, MI325X, MI300X, MI300A

- **Intel**	Jaguar Shores, Falcon Shores, Crescent Island, Max 1550, B580

**🧹 Teardown**

To decommission the simulation and release all local resources:

Bash
chmod +x buildscript_removescript_archdiagram/kwokRemove.sh
./buildscript_removescript_archdiagram/kwokRemove.sh

---
<u>**Justin D. Sniesak**</u>  
*Senior Site Reliability Engineer | Platform Architect*
