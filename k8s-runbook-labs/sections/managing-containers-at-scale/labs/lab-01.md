# Managing at Scale: Understand Scaling Challenges

**Goal**: Demonstrate the complexity of manually managing multiple containers.

## Prereqs

- Docker installed

## Steps

```bash
# Start multiple container instances manually
for i in {1..5}; do
  docker run -d --name web-${i} -p 808${i}:80 nginx:alpine
done

# List all running containers
docker ps

# Check each container's status
for i in {1..5}; do
  echo "Container web-${i}:"
  docker inspect web-${i} --format '{{.State.Status}}'
done

# Simulate a failure - stop one container
docker stop web-3

# Manual "recovery" - restart it
docker start web-3

# This becomes unmanageable at scale!
# Now cleanup all
for i in {1..5}; do
  docker stop web-${i}
  docker rm web-${i}
done
```

## Verify

- All 5 containers start successfully
- Manual management is tedious and error-prone
- Scaling to 100s of containers is impractical

## Cleanup

```bash
for i in {1..5}; do
  docker stop web-${i} 2>/dev/null || true
  docker rm web-${i} 2>/dev/null || true
done
```

## Key Takeaways

- Manual container management doesn't scale
- Need automation for self-healing
- Service discovery becomes complex
- Kubernetes solves these problems
