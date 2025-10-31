# ReplicaSets

ReplicaSets ensure a specified number of pod replicas run at any time. They provide self-healing by creating new pods when existing ones fail.

## Key Features

- Maintains desired replica count
- Label selector identifies managed pods
- Self-healing when pods fail
- Horizontal scaling
- Selector is immutable after creation

## Labs

- [Lab 01: Create and Scale ReplicaSet](labs/lab-01.md)
- [Lab 02: Self-Healing Demo](labs/lab-02.md)
