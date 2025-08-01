#!/bin/sh

DB_NAME="$WP_DB_NAME"
DB_USER="$WP_DB_USER"
DB_PASS="$WP_DB_PASSWORD"
DB_ROOT_PASS="$WP_DB_ROOT_PASSWORD"

# init mysql if not initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "[+] Inizializzazione..."
  mysql_install_db --user=mysql --ldata=/var/lib/mysql

  echo "[+] Creazione DB e utente..."
  mysqld --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

exec mysqld_safe

