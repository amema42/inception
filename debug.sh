#!/bin/bash

echo "=== INCEPTION DEBUG SCRIPT ==="
echo

echo "🔍 Checking containers status..."
docker compose -f srcs/docker-compose.yml ps
echo

echo "🔍 Checking environment variables in MariaDB..."
docker compose -f srcs/docker-compose.yml exec mariadb env | grep WP_
echo

echo "🔍 Testing MariaDB connection..."
docker compose -f srcs/docker-compose.yml exec mariadb mysql -u root -prootpass -e "SHOW DATABASES;" 2>/dev/null || echo "❌ Cannot connect to MariaDB as root"
echo

echo "🔍 Checking if WordPress database exists..."
docker compose -f srcs/docker-compose.yml exec mariadb mysql -u root -prootpass -e "USE wordpress; SHOW TABLES;" 2>/dev/null || echo "❌ WordPress database not found"
echo

echo "🔍 Checking WordPress user..."
docker compose -f srcs/docker-compose.yml exec mariadb mysql -u root -prootpass -e "SELECT User, Host FROM mysql.user WHERE User='wp_user';" 2>/dev/null || echo "❌ Cannot query users"
echo

echo "🔍 Testing WordPress user connection..."
docker compose -f srcs/docker-compose.yml exec mariadb mysql -u wp_user -pwp_pass -e "SELECT 'Connection OK';" 2>/dev/null || echo "❌ WordPress user cannot connect"
echo

echo "🔍 Checking WordPress files..."
docker compose -f srcs/docker-compose.yml exec wordpress ls -la /var/www/html/ | head -10
echo

echo "🔍 Checking wp-config.php..."
docker compose -f srcs/docker-compose.yml exec wordpress grep -E "(DB_NAME|DB_USER|DB_PASSWORD|DB_HOST)" /var/www/html/wp-config.php 2>/dev/null || echo "❌ wp-config.php not found or no DB config"
echo

echo "🔍 Recent MariaDB logs..."
docker compose -f srcs/docker-compose.yml logs mariadb --tail=10
echo

echo "🔍 Recent WordPress logs..."
docker compose -f srcs/docker-compose.yml logs wordpress --tail=10
echo

echo "=== END DEBUG ==="
