#!/bin/bash
set -e

DB_DIR=/var/lib/mysql

if [ ! -d "$DB_DIR/mysql" ]; then
    echo "Initializing MariaDB data directory"
    mariadb-install-db --user=mysql --datadir="$DB_DIR" > /dev/null

    mysqld --skip-networking &
    pid="$!"

    mysql=( mysql --protocol=socket -uroot )
    for i in {30..0}; do
        if "${mysql[@]}" -e "SELECT 1" >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done
    if [ "$i" = 0 ]; then
        echo >&2 'MariaDB init process failed.'
        exit 1
    fi

    root_pass="$(cat "$MYSQL_ROOT_PASSWORD_FILE")"
    user_pass="$(cat "$MYSQL_PASSWORD_FILE")"

    "${mysql[@]}" <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${root_pass}';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${user_pass}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    mysqladmin shutdown -uroot --password="${root_pass}"
    wait "$pid"
fi

exec "$@"
