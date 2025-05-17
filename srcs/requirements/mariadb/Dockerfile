FROM debian:12

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# socket
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

EXPOSE 3306

# mysql in foreground
CMD ["mysqld","--console"]

