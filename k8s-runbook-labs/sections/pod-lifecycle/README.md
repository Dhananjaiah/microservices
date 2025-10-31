# Pod Lifecycle

Pods go through distinct phases from creation to termination: Pending, Running, Succeeded, Failed, and Unknown. Understanding these phases is crucial for debugging and monitoring.

## Pod Phases

- **Pending**: Pod accepted but containers not yet created
- **Running**: Pod bound to node, at least one container running
- **Succeeded**: All containers terminated successfully
- **Failed**: All containers terminated, at least one failed
- **Unknown**: Pod state cannot be determined

## Container States

- **Waiting**: Container waiting to start
- **Running**: Container executing
- **Terminated**: Container finished execution

## Labs

- [Lab 01: Observe Pod Phases](labs/lab-01.md)
- [Lab 02: Init Containers](labs/lab-02.md)
