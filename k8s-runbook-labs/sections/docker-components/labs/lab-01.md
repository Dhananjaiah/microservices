# Docker Components: Explore Components

**Goal**: Understand Docker's core components through hands-on exploration.

## Prereqs

- Docker installed
- Internet connection for pulling images

## Steps

```bash
# Check Docker version and info
docker version
docker info

# Pull an image from registry
docker pull nginx:alpine

# List local images
docker images

# Inspect image layers
docker history nginx:alpine

# Run a container from the image
docker run -d --name web nginx:alpine

# List running containers
docker ps

# Inspect container details
docker inspect web

# View container logs
docker logs web

# Execute command in running container
docker exec web ls /usr/share/nginx/html

# Stop and remove container
docker stop web
docker rm web

# Remove image
docker rmi nginx:alpine
```

## Verify

- Image pulled successfully from Docker Hub
- Container runs and serves HTTP traffic
- Can execute commands inside container

## Cleanup

```bash
docker stop web 2>/dev/null || true
docker rm web 2>/dev/null || true
docker rmi nginx:alpine 2>/dev/null || true
```

## Key Takeaways

- Docker Engine manages the container lifecycle
- Images are pulled from registries (default: Docker Hub)
- Containers are created from images
- Multiple containers can use the same image
