# Rolling Update Strategy

Rolling updates gradually replace old pods with new ones, maintaining availability with zero downtime. This is the default deployment strategy in Kubernetes.

## Characteristics

- Incremental pod replacement
- Zero downtime updates
- Controls via maxSurge and maxUnavailable
- Automatic rollback on failure
- Old and new versions coexist briefly

## Configuration Parameters

- **maxSurge**: Max pods above desired count during update (default: 25%)
- **maxUnavailable**: Max pods unavailable during update (default: 25%)

## Labs

- [Lab 01: Rolling Update Demo](labs/lab-01.md)
- [Lab 02: Configure maxSurge and maxUnavailable](labs/lab-02.md)
