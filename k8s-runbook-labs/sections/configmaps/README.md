# ConfigMaps

ConfigMaps store non-confidential configuration data as key-value pairs. They decouple configuration from container images for portability.

## Usage Methods

- Environment variables
- Command-line arguments
- Configuration files via volume mounts

## Key Features

- Separate config from code
- Update config without rebuilding images
- Multiple pods can share ConfigMaps
- Immutable option for safety

## Labs

- [Lab 01: ConfigMap from Literal](labs/lab-01.md)
- [Lab 02: ConfigMap as Environment Variables](labs/lab-02.md)
- [Lab 03: ConfigMap as Volume](labs/lab-03.md)
