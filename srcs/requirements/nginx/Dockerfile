FROM debian:12

RUN apt-get update \
 && apt-get install -y nginx openssl \
 && rm -rf /var/lib/apt/lists/*

# Copia la configurazione principale
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Crea cartelle e copia i certificati SSL
RUN mkdir -p /etc/nginx/certs /var/log/nginx
COPY server.crt /etc/nginx/certs/server.crt
COPY server.key /etc/nginx/certs/server.key

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

