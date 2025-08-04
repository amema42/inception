#!/bin/sh

# Load passwords from Docker secrets
if [ -f /run/secrets/db_password ]; then
    DB_PASS=$(cat /run/secrets/db_password)
else
    echo "Error: db_password secret not found"
    exit 1
fi

if [ -f /run/secrets/db_root_password ]; then
    DB_ROOT_PASS=$(cat /run/secrets/db_root_password)
else
    echo "Error: db_root_password secret not found"
    exit 1
fi

DB_NAME="$WP_DB_NAME"
DB_USER="$WP_DB_USER"

echo "[DEBUG] Variables loaded:"
echo "DB_NAME: $DB_NAME"
echo "DB_USER: $DB_USER"
echo "DB_PASS: [hidden]"

# Create necessary directories
mkdir -p /var/log/mysql /run/mysqld
chown mysql:mysql /var/log/mysql /run/mysqld

# Init mysql if not initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[+] Initializing MariaDB..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql

    echo "[+] Creating database and user with bootstrap..."
    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF
    
    echo "[+] Database initialization completed"
else
    echo "[i] MariaDB already initialized"
fi

echo "[+] Starting MariaDB..."
exec mysqld_safe --user=mysql