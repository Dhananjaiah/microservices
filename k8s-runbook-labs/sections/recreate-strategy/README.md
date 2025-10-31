# Recreate Strategy

The Recreate strategy terminates all old pods before creating new ones, resulting in downtime but ensuring no mixed versions run simultaneously.

## Characteristics

- All old pods stopped first
- Then new pods started
- Causes downtime during update
- Simple and predictable
- Useful when mixing versions is problematic

## Use Cases

- Database schema changes require all-or-nothing
- Application doesn't support multiple versions
- Testing environments where downtime is acceptable

## Labs

- [Lab 01: Recreate Strategy Demo](labs/lab-01.md)
