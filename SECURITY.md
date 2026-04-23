# Security Policy

## Supported Versions

Currently supported versions with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability, please follow these steps:

1. **Do NOT** open a public issue
2. Email the maintainers directly (add your email here)
3. Include detailed information:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Security Best Practices

When deploying this system:

- Change default passwords in `.env` file
- Use strong passwords for database and Redis
- Enable SSL/TLS for production deployments
- Restrict network access to services
- Keep dependencies updated
- Monitor logs for suspicious activity
- Use environment variables for secrets
- Never commit credentials to version control

## Known Security Considerations

- MQTT broker uses no authentication by default (configure for production)
- WebSocket connections are not authenticated (add auth layer for production)
- Slack webhook URL should be kept secret
- Database credentials should be rotated regularly

## Updates

Security updates will be released as patch versions. Subscribe to releases to stay informed.
