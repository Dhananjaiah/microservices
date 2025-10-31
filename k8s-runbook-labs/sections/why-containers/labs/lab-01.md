# Why Containers: Understanding Container Benefits

**Goal**: Demonstrate container portability and efficiency compared to traditional deployment.

## Prereqs

- Docker installed (or kind/minikube with Docker runtime)
- `kubectl` available

## Steps

```bash
# Run a simple web server in a container
docker run -d --name demo-web -p 8080:80 nginx:alpine

# Verify it's running
curl http://localhost:8080

# Check resource usage
docker stats demo-web --no-stream

# View container details
docker inspect demo-web

# Stop and remove
docker stop demo-web
docker rm demo-web
```

## Verify

Container should start in under 2 seconds and respond to HTTP requests immediately.

## Cleanup

```bash
docker stop demo-web 2>/dev/null || true
docker rm demo-web 2>/dev/null || true
```

## Key Takeaways

- Containers start much faster than VMs (seconds vs minutes)
- Lightweight - alpine image is only ~5MB
- Portable - same image runs on any Docker host
- Isolated - doesn't affect host or other containers
