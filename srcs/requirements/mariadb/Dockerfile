FROM debian:12

# Install MariaDB
RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY my.cnf /etc/mysql/my.cnf

# Setup directories and permissions
RUN mkdir -p /run/mysqld /var/log/mysql && \
    chown mysql:mysql /run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/lib/mysql

# Copy and set executable entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]
