FROM debian:12

RUN apt-get update \
 && apt-get install -y nginx \
 && rm -rf /var/lib/apt/lists/*

# Copy main configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Create directory for mounted certificates
RUN mkdir -p /etc/nginx/certs

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]

