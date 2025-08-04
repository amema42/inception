#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Inception Project Setup${NC}"
echo "======================="

# Create directories if they don't exist
mkdir -p secrets srcs

# 1. GENERATE SSL CERTIFICATES
echo -e "${YELLOW}[1/5]${NC} Generating SSL certificates..."

if [ ! -f "secrets/server.crt" ] || [ ! -f "secrets/server.key" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout secrets/server.key \
        -out secrets/server.crt \
        -subj "/C=IT/ST=42/L=Roma/O=Inception/CN=amema.42.fr"
    echo -e "${GREEN}[OK]${NC} SSL certificates generated for amema.42.fr"
else
    echo -e "${YELLOW}[SKIP]${NC} SSL certificates already exist"
fi

# 2. GENERATE SECURE SECRETS
echo -e "${YELLOW}[2/5]${NC} Generating secure secrets..."

if [ ! -f "secrets/db_password.txt" ]; then
    DB_PASS=$(openssl rand -base64 12 | tr -d "=+/" | cut -c1-16)
    echo "$DB_PASS" > secrets/db_password.txt
    echo -e "${GREEN}[OK]${NC} Database password generated"
else
    echo -e "${YELLOW}[SKIP]${NC} Database password already exists"
fi

if [ ! -f "secrets/db_root_password.txt" ]; then
    ROOT_PASS=$(openssl rand -base64 12 | tr -d "=+/" | cut -c1-16)
    echo "$ROOT_PASS" > secrets/db_root_password.txt
    echo -e "${GREEN}[OK]${NC} Root password generated"
else
    echo -e "${YELLOW}[SKIP]${NC} Root password already exists"
fi

# 3. CREATE ENVIRONMENT FILE
echo -e "${YELLOW}[3/5]${NC} Creating environment file..."

if [ ! -f "srcs/.env" ]; then
    cat > srcs/.env << EOF
# Generated automatically by setup script
# Database Configuration
WP_DB_NAME=wordpress
WP_DB_USER=wp_user

# WordPress Configuration  
WORDPRESS_DB_HOST=mariadb
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wp_user

# WordPress Site Configuration
WP_TITLE=Inception42
WP_ADMIN_USR=biguser42
WP_ADMIN_PWD=superDevSeC$(openssl rand -hex 4)!
WP_ADMIN_EMAIL=amema@student.42roma.it
WP_USR=guestuser42
WP_EMAIL=amema1@student.42roma.it
WP_PWD=gUeStPws$(openssl rand -hex 3)!

# Domain Configuration
DOMAIN_NAME=${USER}.42.fr
EOF
    echo -e "${GREEN}[OK]${NC} Environment file created"
else
    echo -e "${YELLOW}[SKIP]${NC} Environment file already exists"
fi

# 4. CREATE DATA DIRECTORIES
echo -e "${YELLOW}[4/5]${NC} Creating data directories..."

DATA_DIR="/home/$USER/data"
mkdir -p "$DATA_DIR/mariadb" "$DATA_DIR/wordpress"
echo -e "${GREEN}[OK]${NC} Data directories created at $DATA_DIR"

# 5. CONFIGURE DOMAIN IN /etc/hosts IF NEEDED
echo -e "${YELLOW}[5/5]${NC} Checking domain configuration..."

DOMAIN="${USER}.42.fr"
if ! grep -q "$DOMAIN" /etc/hosts 2>/dev/null; then
    echo -e "${YELLOW}[INFO]${NC} Please add this to /etc/hosts:"
    echo -e "${GREEN}       127.0.0.1 $DOMAIN${NC}"
    echo
    read -p "Add automatically? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
        echo -e "${GREEN}[OK]${NC} Domain added to /etc/hosts"
    else
        echo -e "${YELLOW}[MANUAL]${NC} Please add domain manually"
    fi
else
    echo -e "${GREEN}[OK]${NC} Domain already configured"
fi

echo
echo -e "${GREEN}Setup completed successfully${NC}"
echo -e "Website will be available at: ${BLUE}https://$DOMAIN${NC}"
