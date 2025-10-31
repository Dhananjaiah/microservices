# Deployments

Deployments provide declarative updates for Pods and ReplicaSets. They enable rolling updates, rollbacks, and maintain revision history for easy recovery.

## Key Features

- Declarative pod and ReplicaSet management
- Rolling updates with zero downtime
- Rollback to previous versions
- Revision history tracking
- Pause/resume deployments

## Update Strategies

- **Rolling Update**: Gradual replacement (default)
- **Recreate**: All-at-once replacement

## Labs

- [Lab 01: Create and Update Deployment](labs/lab-01.md)
- [Lab 02: Rollback Deployment](labs/lab-02.md)
- [Lab 03: Bad Image Rollout](labs/lab-03.md)
