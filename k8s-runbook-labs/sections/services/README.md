# Services

Services provide stable network endpoints for pods. They enable service discovery and load balancing across pod replicas using label selectors.

## Service Types

- **ClusterIP**: Internal-only access (default)
- **NodePort**: Exposes service on each node's IP at a static port
- **LoadBalancer**: Exposes service via cloud provider's load balancer
- **ExternalName**: Maps service to DNS name

## Key Concepts

- Label selectors connect services to pods
- Endpoints track pod IPs
- Services provide stable DNS names
- Load balancing across healthy pods

## Labs

- [Lab 01: ClusterIP Service](labs/lab-01.md)
- [Lab 02: NodePort Service](labs/lab-02.md)
- [Lab 03: Port Forwarding](labs/lab-03.md)
