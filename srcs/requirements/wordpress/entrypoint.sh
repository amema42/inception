#!/bin/sh

# Directory dove installare WordPress
WP_PATH="/var/www/html"

# Scarica WordPress solo se non esiste già
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
  echo "[+] Downloading WordPress..."
  mkdir -p "$WP_PATH"
  wget -q https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
  tar -xzf /tmp/wordpress.tar.gz --strip-components=1 -C "$WP_PATH"
  rm /tmp/wordpress.tar.gz
  chown -R www-data:www-data "$WP_PATH"

  echo "[+] Configuring wp-config.php..."
  wp core config \
    --path="$WP_PATH" \
    --dbname="$WP_DB_NAME" \
    --dbuser="$WP_DB_USER" \
    --dbpass="$WP_DB_PASSWORD" \
    --dbhost="mariadb" \
    --skip-check \
    --allow-root

  echo "[+] Installing WordPress..."
  wp core install \
    --path="$WP_PATH" \
    --url="https://${DOMAIN_NAME}" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

  echo "[+] Creating non-admin user..."
  wp user create "$WP_USER" "$WP_USER_EMAIL" \
    --user_pass="$WP_USER_PASSWORD" \
    --role=subscriber \
    --path="$WP_PATH" \
    --allow-root
else
  echo "[i] WordPress already installed, skipping setup."
fi

echo "[+] Starting php-fpm..."
exec php-fpm -F

