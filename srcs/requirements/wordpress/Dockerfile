FROM debian:12

# Installa PHP-FPM, estensioni, wget e wp-cli
RUN apt-get update \
 && apt-get install -y php-fpm php-mysql wget tar curl less \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /usr/sbin/php-fpm8.2 /usr/sbin/php-fpm \
 && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x wp-cli.phar \
 && mv wp-cli.phar /usr/local/bin/wp

# Configura PHP-FPM per ascoltare su TCP:9000
RUN sed -i 's|^;*\s*listen\s*=.*|listen = 0.0.0.0:9000|' /etc/php/*/fpm/pool.d/www.conf

# Copia entrypoint personalizzato
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["/entrypoint.sh"]

