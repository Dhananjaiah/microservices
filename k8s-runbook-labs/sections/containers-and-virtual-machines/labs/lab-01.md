# Containers and VMs: Compare Characteristics

**Goal**: Observe and compare container resource usage and startup characteristics.

## Prereqs

- Docker installed
- `kubectl` available

## Steps

```bash
# Check container image sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | head -10

# Run a container and measure startup time
time docker run --rm alpine echo "Container started"

# Check container resource limits
docker run --rm alpine cat /sys/fs/cgroup/memory/memory.limit_in_bytes

# Compare with system total memory
free -h

# Run a container with limited resources
docker run -d --name limited --memory="128m" --cpus="0.5" nginx:alpine

# Check resource usage
docker stats limited --no-stream

# Cleanup
docker stop limited
docker rm limited
```

## Verify

- Container startup should be < 1 second
- Container image size should be small (alpine ~5MB)
- Resource limits are enforced by cgroups

## Cleanup

```bash
docker stop limited 2>/dev/null || true
docker rm limited 2>/dev/null || true
```

## Key Takeaways

- Containers share the host kernel (no guest OS overhead)
- Much faster startup than VMs
- Efficient resource usage through cgroups
- Smaller footprint than VMs
