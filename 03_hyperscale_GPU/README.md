Phase 3 repo.

```
├── buildscript_removescript_archdiagram/
│   ├── hyperscaleautomation.sh
│   ├── hyperscaleGPUFleet.drawio.png
│   └── kwokRemove.sh
├── hyperscale_output_deployments/   # Pod-level validation receipts (20 pairs)
│   ├── a30Deployment.txt
│   ├── a30PodsGPUCount.txt
│   ├── a100Deployment.txt
│   ├── a100PodsGPUCount.txt
│   ├── b100Deployment.txt
│   ├── b100PodsGPUCount.txt
│   ├── b200Deployment.txt
│   ├── b200PodsGPUCount.txt
│   ├── b580Deployment.txt
│   ├── b580PodsGPUCount.txt
│   ├── crescentIslandDeployment.txt
│   ├── crescentIslandPodsGPUCount.txt
│   ├── falconShoresDeployment.txt
│   ├── falconShoresPodsGPUCount.txt
│   ├── gb200Deployment.txt
│   ├── gb200PodsGPUCount.txt
│   ├── h100Deployment.txt
│   ├── h100PodsGPUCount.txt
│   ├── h200Deployment.txt
│   ├── h200PodsGPUCount.txt
│   ├── jaguarShoresDeployment.txt
│   ├── jaguarShoresPodsGPUCount.txt
│   ├── l4Deployment.txt
│   ├── l4PodsGPUCount.txt
│   ├── max1550Deployment.txt
│   ├── max1550PodsGPUCount.txt
│   ├── mi300aDeployment.txt
│   ├── mi300aPodsGPUCount.txt
│   ├── mi300xDeployment.txt
│   ├── mi300xPodsGPUCount.txt
│   ├── mi325xDeployment.txt
│   ├── mi325xPodsGPUCount.txt
│   ├── mi350xDeployment.txt
│   ├── mi350xPodsGPUCount.txt
│   ├── mi355xDeployment.txt
│   ├── mi355xPodsGPUCount.txt
│   ├── t4Deployment.txt
│   ├── t4PodsGPUCount.txt
│   ├── v100Deployment.txt
│   └── v100PodsGPUCount.txt
├── hyperscale_output_nodes/         # Node-level inventory receipts (20 pairs)
│   ├── a30Nodes.txt
│   ├── a30NodeGPUCount.txt
│   ├── a100Nodes.txt
│   ├── a100NodeGPUCount.txt
│   ├── b100Nodes.txt
│   ├── b100NodeGPUCount.txt
│   ├── b200Nodes.txt
│   ├── b200NodeGPUCount.txt
│   ├── b580Nodes.txt
│   ├── b580NodeGPUCount.txt
│   ├── crescentIslandNodes.txt
│   ├── crescentIslandNodeGPUCount.txt
│   ├── falconShoresNodes.txt
│   ├── falconShoresNodeGPUCount.txt
│   ├── gb200Nodes.txt
│   ├── gb200NodeGPUCount.txt
│   ├── h100Nodes.txt
│   ├── h100NodeGPUCount.txt
│   ├── h200Nodes.txt
│   ├── h200NodeGPUCount.txt
│   ├── jaguarShoresNodes.txt
│   ├── jaguarShoresNodeGPUCount.txt
│   ├── l4Nodes.txt
│   ├── l4NodeGPUCount.txt
│   ├── max1550Nodes.txt
│   ├── max1550NodeGPUCount.txt
│   ├── mi300aNodes.txt
│   ├── mi300aNodeGPUCount.txt
│   ├── mi300xNodes.txt
│   ├── mi300xNodeGPUCount.txt
│   ├── mi325xNodes.txt
│   ├── mi325xNodeGPUCount.txt
│   ├── mi350xNodes.txt
│   ├── mi350xNodeGPUCount.txt
│   ├── mi355xNodes.txt
│   ├── mi355xNodeGPUCount.txt
│   ├── t4Nodes.txt
│   ├── t4NodeGPUCount.txt
│   ├── v100Nodes.txt
│   └── v100NodeGPUCount.txt
├── manifests/
│   ├── deployments/                 # 20 Deployment YAMLs
│   │   ├── a30Deployment.yaml
│   │   ├── a100Deployment.yaml
│   │   ├── b100Deployment.yaml
│   │   ├── b200Deployment.yaml
│   │   ├── b580Deployment.yaml
│   │   ├── crescentIslandDeployment.yaml
│   │   ├── falconShoresDeployment.yaml
│   │   ├── gb200Deployment.yaml
│   │   ├── h100Deployment.yaml
│   │   ├── h200Deployment.yaml
│   │   ├── jaguarShoresDeployment.yaml
│   │   ├── l4Deployment.yaml
│   │   ├── max1550Deployment.yaml
│   │   ├── mi300aDeployment.yaml
│   │   ├── mi300xDeployment.yaml
│   │   ├── mi325xDeployment.yaml
│   │   ├── mi350xDeployment.yaml
│   │   ├── mi355xDeployment.yaml
│   │   ├── t4Deployment.yaml
│   │   └── v100Deployment.yaml
│   └── nodes/                       # 20 KWOK Node manifests
│       ├── kwokNodesA30.yaml
│       ├── kwokNodesA100.yaml
│       ├── kwokNodesB100.yaml
│       ├── kwokNodesB200.yaml
│       ├── kwokNodesB580.yaml
│       ├── kwokNodesCrescentIsland.yaml
│       ├── kwokNodesFalconShores.yaml
│       ├── kwokNodesGB200.yaml
│       ├── kwokNodesH100.yaml
│       ├── kwokNodesH200.yaml
│       ├── kwokNodesJaguarShores.yaml
│       ├── kwokNodesL4.yaml
│       ├── kwokNodesMax1550.yaml
│       ├── kwokNodesmi300a.yaml
│       ├── kwokNodesmi300x.yaml
│       ├── kwokNodesmi325x.yaml
│       ├── kwokNodesmi350x.yaml
│       ├── kwokNodesmi355x.yaml
│       ├── kwokNodesT4.yaml
│       └── kwokNodesV100.yaml
├── screenshots/
└── scripts/                         # Supporting for-loop bash scripts
    ├── a30Nodes.sh
    ├── a100Nodes.sh
    ├── b100Nodes.sh
    ├── b200Nodes.sh
    ├── b580Nodes.sh
    ├── crescentIslandNodes.sh
    ├── falconShoresNodes.sh
    ├── gb200Nodes.sh
    ├── h100Nodes.sh
    ├── h200Nodes.sh
    ├── jaguarShoresNodes.sh
    ├── l4Nodes.sh
    ├── max1550Nodes.sh
    ├── mi300aNodes.sh
    ├── mi300xNodes.sh
    ├── mi325xNodes.sh
    ├── mi350xNodes.sh
    ├── mi355xNodes.sh
    ├── t4Nodes.sh
    └── v100Nodes.sh
```
