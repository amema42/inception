#!/bin/bash

# WordPress installation directory
WP_PATH="/var/www/html"

# Load database password from secret
if [ -f /run/secrets/db_password ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password)
else
    echo "Error: db_password secret not found"
    exit 1
fi

# Create directory if it doesn't exist
mkdir -p "$WP_PATH"

# Wait for MariaDB to be ready
echo "[+] Waiting for MariaDB to be ready..."
until mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$DB_PASSWORD" -e 'SELECT 1' >/dev/null 2>&1; do
  echo "Waiting for MariaDB connection..."
  sleep 2
done
echo "[+] MariaDB is ready!"

# Download WordPress only if not already installed
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
  echo "[+] Downloading WordPress..."
  
  cd "$WP_PATH"
  rm -rf *
  
  # Install wp-cli
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar 
  chmod +x wp-cli.phar 
  mv wp-cli.phar /usr/local/bin/wp
  
  # Download WordPress
  wp core download --allow-root
  
  # Configure wp-config.php
  wp config create \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$DB_PASSWORD" \
    --dbhost="$WORDPRESS_DB_HOST" \
    --allow-root
  
  # Install WordPress
  wp core install \
    --url="https://$DOMAIN_NAME/" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USR" \
    --admin_password="$WP_ADMIN_PWD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root
  
  # Create non-admin user
  wp user create "$WP_USR" "$WP_EMAIL" \
    --role=author \
    --user_pass="$WP_PWD" \
    --allow-root
  
  echo "[+] WordPress installation completed!"
else
  echo "[i] WordPress already installed"
fi

# Configure PHP-FPM for TCP
sed -i 's/listen = \/run\/php\/php8.2-fpm.sock/listen = 9000/g' /etc/php/8.2/fpm/pool.d/www.conf

# Create directory for PHP-FPM
mkdir -p /run/php

# Change ownership
chown -R www-data:www-data "$WP_PATH"

echo "[+] Starting PHP-FPM..."
exec /usr/sbin/php-fpm8.2 -F