# Docker Components: Build Custom Image

**Goal**: Create a custom Docker image using a Dockerfile.

## Prereqs

- Docker installed
- Basic text editor

## Steps

```bash
# Create a working directory
mkdir -p /tmp/docker-build && cd /tmp/docker-build

# Create a simple HTML file
cat > index.html <<'EOF'
<!DOCTYPE html>
<html>
<head><title>K8s Runbook</title></head>
<body>
<h1>Hello from Custom Container!</h1>
<p>This is a custom Docker image.</p>
</body>
</html>
EOF

# Create Dockerfile
cat > Dockerfile <<'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Build the image
docker build -t custom-web:v1 .

# View build layers
docker history custom-web:v1

# Run container from custom image
docker run -d --name custom -p 8081:80 custom-web:v1

# Test the custom content
curl http://localhost:8081

# Stop and cleanup
docker stop custom
docker rm custom
docker rmi custom-web:v1
```

## Verify

- Image builds successfully
- Custom HTML content is served
- Image includes only specified layers

## Cleanup

```bash
docker stop custom 2>/dev/null || true
docker rm custom 2>/dev/null || true
docker rmi custom-web:v1 2>/dev/null || true
rm -rf /tmp/docker-build
```

## Key Takeaways

- Dockerfiles define image build steps
- Images are built in layers (cached for efficiency)
- Custom images extend base images
- Each instruction creates a new layer
