# Scaling In a Cluster

Scaling in removes nodes to reduce cluster size and costs. Requires draining nodes first to safely migrate workloads.

## Process

1. Cordon node to prevent new pods
2. Drain node to evict existing pods
3. Remove/delete node from cluster
4. Verify workloads redistributed

## Considerations

- Ensure sufficient capacity remains
- Use PodDisruptionBudgets for safety
- Graceful workload migration
- Cost optimization in cloud

## Labs

- [Lab 01: Scale In Workflow](labs/lab-01.md)
