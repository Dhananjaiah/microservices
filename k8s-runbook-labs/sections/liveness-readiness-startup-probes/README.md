# Liveness, Readiness and Startup Probes

Probes monitor container health to ensure reliable application operation. They enable automatic recovery and intelligent load balancing.

## Probe Types

- **Liveness**: Restart unhealthy containers
- **Readiness**: Control traffic to healthy containers only
- **Startup**: Handle slow-starting applications

## Probe Mechanisms

- **HTTP GET**: Check HTTP endpoint
- **TCP Socket**: Verify TCP connection
- **Exec**: Run command in container

## Configuration

- initialDelaySeconds, periodSeconds, timeoutSeconds
- successThreshold, failureThreshold

## Labs

- [Lab 01: Liveness Probe](labs/lab-01.md)
- [Lab 02: Readiness Probe](labs/lab-02.md)
- [Lab 03: Startup Probe](labs/lab-03.md)
