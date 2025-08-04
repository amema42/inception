# Inception

A containerized WordPress stack implementing a three-tier architecture with NGINX reverse proxy, WordPress with PHP-FPM, and MariaDB database.

## Getting Started

### Prerequisites

- Docker Engine (>= 20.10)
- Docker Compose (>= 1.29)
- OpenSSL
- Linux environment with sudo privileges

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd inception
```

2. Run the automated setup:
```bash
make all
```

3. Configure domain resolution:
```bash
# Add to /etc/hosts (done automatically if confirmed during setup)
echo "127.0.0.1 amema.42.fr" | sudo tee -a /etc/hosts
```

4. Access the WordPress site:
```bash
https://amema.42.fr
```

### Usage

Start services:
```bash
make up
```

Stop services:
```bash
make down
```

Clean environment:
```bash
make clean      # Remove containers and generated files
make fclean     # Complete cleanup including data volumes
```

## Project Structure

```
inception/
├── Makefile                    # Build automation and lifecycle management
├── docker-compose.yml          # Service orchestration configuration
├── scripts/
│   └── setup.sh               # Environment initialization script
├── secrets/                   # Generated certificates and passwords (git-ignored)
│   ├── server.crt            # SSL certificate
│   ├── server.key            # SSL private key
│   ├── db_password.txt       # WordPress database user password
│   └── db_root_password.txt  # MariaDB root password
└── srcs/
    ├── .env                   # Environment variables (git-ignored)
    ├── .env.example          # Environment template
    └── requirements/
        ├── mariadb/          # MariaDB container configuration
        │   ├── Dockerfile
        │   ├── entrypoint.sh
        │   └── my.cnf
        ├── nginx/            # NGINX reverse proxy configuration
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        └── wordpress/        # WordPress with PHP-FPM configuration
            ├── Dockerfile
            └── entrypoint.sh
```

## Main Components

### NGINX (Reverse Proxy)
- Handles HTTPS termination with TLS 1.2/1.3
- Serves static files and proxies PHP requests to WordPress container
- Configured with custom SSL certificates
- Listens on port 443 only

### WordPress (Application Layer)
- PHP-FPM based WordPress installation
- Automated setup with WP-CLI
- Creates admin and author users during initialization
- Connects to MariaDB via Docker networking

### MariaDB (Database Layer)
- Persistent database storage with Docker volumes
- Automatic database and user creation
- Configured for container networking with bind-address 0.0.0.0
- Uses Docker secrets for password management

### Data Flow
1. HTTPS requests arrive at NGINX on port 443
2. Static files served directly by NGINX
3. PHP requests forwarded to WordPress container via FastCGI
4. WordPress communicates with MariaDB over internal Docker network
5. Database data persisted to host filesystem via bind mounts



