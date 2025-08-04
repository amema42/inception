# Documentation

## Overview

This project implements a three-tier containerized web application stack following microservices principles. The architecture consists of presentation layer (NGINX), application layer (WordPress/PHP-FPM), and data layer (MariaDB).

## System Components

### Container Network

```
[Client] --HTTPS--> [NGINX:443] --FastCGI--> [WordPress:9000] --MySQL--> [MariaDB:3306]
```

All containers communicate over a custom Docker bridge network named `inception`. No external network access is required for inter-container communication.

### Security Model

- **SSL/TLS**: NGINX terminates HTTPS with TLS 1.2/1.3 protocols only
- **Secrets Management**: Docker secrets for database credentials, mounted as read-only files
- **Network Isolation**: Custom bridge network isolates containers from default Docker network
- **File Permissions**: Containers run with least-privilege user accounts

## Component Details

### NGINX Container

**Base Image**: debian:12  
**Port**: 443 (HTTPS only)  
**Function**: Reverse proxy and SSL termination

#### Configuration
- SSL certificates mounted from host filesystem at `/etc/nginx/certs/`
- FastCGI proxy configuration for PHP processing
- Static file serving for WordPress assets
- Security headers and SSL configuration

#### Critical Files
- `/etc/nginx/nginx.conf`: Main configuration with upstream PHP-FPM backend
- `/etc/nginx/certs/server.crt`: SSL certificate (auto-generated)
- `/etc/nginx/certs/server.key`: SSL private key (auto-generated)

### WordPress Container

**Base Image**: debian:12  
**Port**: 9000 (PHP-FPM)  
**Function**: Application server

#### Initialization Process
1. Wait for MariaDB connection availability
2. Download WordPress core if not present
3. Generate `wp-config.php` with database credentials
4. Execute WordPress installation via WP-CLI
5. Create admin and author user accounts
6. Configure PHP-FPM for TCP socket communication

#### Dependencies
- WP-CLI for automated WordPress management
- PHP-FPM 8.2 with MySQL extensions
- MariaDB client for database connectivity checks

#### Data Persistence
WordPress files persisted to `/home/$USER/data/wordpress` via bind mount.

### MariaDB Container

**Base Image**: debian:12  
**Port**: 3306 (MySQL protocol)  
**Function**: Database server

#### Initialization Process
1. Load credentials from Docker secrets
2. Initialize MySQL data directory if not present
3. Create WordPress database and user with appropriate privileges
4. Configure for network access (bind-address 0.0.0.0)

#### Configuration
- UTF8MB4 character set for full Unicode support
- Optimized for container environment (skip-external-locking)
- Custom socket and PID file locations
- Error logging to `/var/log/mysql/error.log`

#### Data Persistence
Database files persisted to `/home/$USER/data/mariadb` via bind mount.

## Deployment Process

### Automated Setup (`scripts/setup.sh`)

1. **Certificate Generation**: Creates self-signed SSL certificate for domain
2. **Secret Generation**: Generates cryptographically secure database passwords
3. **Environment Configuration**: Creates `.env` file with deployment-specific variables
4. **Directory Creation**: Ensures data directories exist with correct permissions
5. **Domain Configuration**: Optionally updates `/etc/hosts` for local resolution

### Container Orchestration

Docker Compose manages service dependencies:
- MariaDB starts first (no dependencies)
- WordPress waits for MariaDB (depends_on)
- NGINX waits for WordPress (depends_on)

All containers configured with `restart: always` for automatic recovery.

## Data Flow

### HTTP Request Processing

1. Client connects to `https://$DOMAIN_NAME:443`
2. NGINX performs SSL handshake and terminates encryption
3. For PHP requests: NGINX proxies to WordPress container via FastCGI
4. For static files: NGINX serves directly from shared volume
5. WordPress processes PHP and queries MariaDB as needed
6. Response flows back through NGINX to client

### Database Connectivity

WordPress connects to MariaDB using:
- **Host**: Container name `mariadb` (Docker DNS resolution)
- **Port**: 3306 (standard MySQL port)
- **Credentials**: Loaded from Docker secrets at runtime
- **Database**: Auto-created during MariaDB initialization

### File System Layout

```
/home/$USER/data/
├── mariadb/          # Database files (owned by mysql:mysql)
│   ├── mysql/        # System databases
│   ├── wordpress/    # Application database
│   └── ...
└── wordpress/        # WordPress application files (owned by www-data:www-data)
    ├── wp-content/   # Themes, plugins, uploads
    ├── wp-config.php # Database configuration
    └── ...
```

## Environment Variables

### Database Configuration
- `WP_DB_NAME`: WordPress database name
- `WP_DB_USER`: Database user for WordPress
- `WORDPRESS_DB_HOST`: Database hostname (container name)
- `WORDPRESS_DB_NAME`: Database name (same as WP_DB_NAME)
- `WORDPRESS_DB_USER`: Database user (same as WP_DB_USER)

### WordPress Configuration
- `WP_TITLE`: Site title
- `WP_ADMIN_USR`: Administrator username
- `WP_ADMIN_PWD`: Administrator password
- `WP_ADMIN_EMAIL`: Administrator email
- `WP_USR`: Regular user username
- `WP_EMAIL`: Regular user email
- `WP_PWD`: Regular user password
- `DOMAIN_NAME`: Site domain name

## Error Handling

### Container Health Monitoring
- Containers restart automatically on failure
- No explicit health checks implemented (relies on process monitoring)

### Database Connection Resilience
WordPress container implements retry logic for database connections:
```bash
until mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$DB_PASSWORD" -e 'SELECT 1'; do
  sleep 2
done
```

### Graceful Degradation
- NGINX serves 502 errors if WordPress container unavailable
- Database connection failures prevent WordPress initialization
- Missing secrets cause container startup failure

## Security Considerations

### Credential Management
- Database passwords generated using OpenSSL random functions
- Docker secrets mounted read-only in containers
- Secrets excluded from version control via `.gitignore`

### Network Security
- Only port 443 exposed to host network
- Inter-container communication via private bridge network
- No direct database access from external networks

### File System Security
- Containers run as non-root users where possible
- Bind mounts use absolute paths to prevent path traversal
- SSL certificates have restrictive file permissions

## Troubleshooting

### Common Issues

**Container won't start**:
- Check Docker secrets exist and are readable
- Verify data directories exist and have correct permissions
- Review container logs: `docker logs <container_name>`

**WordPress database connection errors**:
- Verify MariaDB container is running
- Check environment variables match between containers
- Confirm Docker secrets contain valid credentials

**SSL certificate errors**:
- Verify certificates exist in `secrets/` directory
- Check certificate CN matches domain name
- Ensure certificates are mounted correctly in NGINX container

### Debug Commands

```bash
# View container logs
docker logs mariadb
docker logs wordpress  
docker logs nginx

# Inspect container configuration
docker inspect <container_name>

# Access container shell
docker exec -it <container_name> /bin/bash

# Test database connectivity
docker exec wordpress mysql -hmariadb -uwp_user -p -e "SHOW DATABASES;"

# Verify NGINX configuration
docker exec nginx nginx -t
```

## Maintenance

### Data Backup
Database and WordPress files persisted in `/home/$USER/data/` should be included in regular backup procedures.

### Security Updates
Base images should be rebuilt periodically to incorporate security updates:
```bash
make fclean  # Remove all containers and images
make all     # Rebuild from latest base images
```

### Log Rotation
Container logs managed by Docker daemon. Configure log rotation in Docker daemon configuration if needed.
