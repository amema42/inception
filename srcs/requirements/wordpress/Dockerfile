FROM debian:12

RUN apt-get update \
 && apt-get install -y php-fpm php-mysql wget tar \
 && rm -rf /var/lib/apt/lists/* \
 # Symlink php-fpm8.2 → php-fpm
 && ln -sf /usr/sbin/php-fpm8.2 /usr/sbin/php-fpm

# Configura PHP-FPM per ascoltare TCP:9000
RUN sed -i 's|^;*\s*listen\s*=.*|listen = 0.0.0.0:9000|' /etc/php/*/fpm/pool.d/www.conf

RUN mkdir -p /var/www/html
RUN wget https://wordpress.org/latest.tar.gz \
 && tar xzf latest.tar.gz -C /var/www/html --strip-components=1 \
 && rm latest.tar.gz \
 && chown -R www-data:www-data /var/www/html

EXPOSE 9000
CMD ["php-fpm", "-F"]

