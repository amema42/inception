FROM debian:12

# install PHP-FPM, MySQL extensions, wget and mariadb-client
RUN apt-get update \
 && apt-get install -y php-fpm php-mysql wget tar curl mariadb-client \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /usr/sbin/php-fpm8.2 /usr/sbin/php-fpm

# Copy custom entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["/entrypoint.sh"]
