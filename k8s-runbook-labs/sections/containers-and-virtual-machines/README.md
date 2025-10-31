# Containers and Virtual Machines

Containers share the host OS kernel and virtualize at the OS level, while VMs include a full OS and virtualize at the hardware level. Containers are more lightweight but VMs provide stronger isolation.

## Architecture Comparison

```mermaid
graph TB
    subgraph "Virtual Machines"
        HW1[Hardware]
        HV[Hypervisor]
        VM1[VM: Guest OS + App]
        VM2[VM: Guest OS + App]
        HW1 --> HV
        HV --> VM1
        HV --> VM2
    end
    
    subgraph "Containers"
        HW2[Hardware]
        OS[Host OS]
        RT[Container Runtime]
        C1[Container: App]
        C2[Container: App]
        HW2 --> OS
        OS --> RT
        RT --> C1
        RT --> C2
    end
```

## Key Differences

- **Startup Time**: Containers (seconds) vs VMs (minutes)
- **Size**: Containers (MBs) vs VMs (GBs)
- **Isolation**: Containers (process-level) vs VMs (hardware-level)
- **Overhead**: Containers (minimal) vs VMs (full OS)

## Labs

- [Lab 01: Compare Container vs VM Characteristics](labs/lab-01.md)
