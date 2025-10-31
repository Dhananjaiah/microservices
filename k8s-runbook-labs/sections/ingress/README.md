# Ingress

Ingress manages external HTTP/HTTPS access to services in a cluster. It provides load balancing, SSL termination, and name-based virtual hosting.

## Features

- Path-based routing
- Host-based routing
- TLS/SSL termination
- Load balancing
- Name-based virtual hosts

## Requirements

- Ingress Controller (nginx, traefik, etc.)
- Ingress resources defining rules

## Common Controllers

- NGINX Ingress Controller
- Traefik
- HAProxy
- Cloud provider ingress (ALB, GCE)

## Labs

- [Lab 01: Install NGINX Ingress Controller](labs/lab-01.md)
- [Lab 02: Path-Based Routing](labs/lab-02.md)
- [Lab 03: Host-Based Routing](labs/lab-03.md)
