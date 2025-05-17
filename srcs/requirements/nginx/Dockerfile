FROM debian:12

RUN apt-get update \
 && apt-get install -y nginx openssl \
 && rm -rf /var/lib/apt/lists/*

# copia solo la configurazione principale
COPY conf/nginx.conf /etc/nginx/nginx.conf

# crea la cartella per i certificati
RUN mkdir -p /etc/nginx/certs \
 && mkdir -p /var/log/nginx

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
