# DaemonSet

DaemonSets ensure a copy of a pod runs on all (or selected) nodes. Used for node-level operations like logging, monitoring, and network management.

## Characteristics

- One pod per node (by default)
- Pods created automatically on new nodes
- Node selectors for targeted deployment
- Survives node drain (requires --ignore-daemonsets)

## Common Use Cases

- Log collection (Fluentd, Filebeat)
- Monitoring agents (Prometheus Node Exporter)
- Network plugins (Calico, Cilium)
- Storage daemons (Ceph, Gluster)

## Labs

- [Lab 01: Create DaemonSet](labs/lab-01.md)
- [Lab 02: Node Selector](labs/lab-02.md)
