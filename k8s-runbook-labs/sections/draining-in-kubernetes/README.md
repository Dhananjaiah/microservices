# Draining in Kubernetes

Draining safely evicts pods from a node for maintenance. It respects PodDisruptionBudgets and gracefully terminates pods before node operations.

## Commands

- **kubectl cordon**: Mark node unschedulable (no new pods)
- **kubectl drain**: Evict pods and cordon node
- **kubectl uncordon**: Mark node schedulable again

## Drain Safety

- Respects PodDisruptionBudgets
- Graceful pod termination
- DaemonSet pods require --ignore-daemonsets
- Local data loss without PVs (use --delete-emptydir-data)

## Labs

- [Lab 01: Cordon and Drain Node](labs/lab-01.md)
- [Lab 02: Drain with Daemonsets](labs/lab-02.md)
