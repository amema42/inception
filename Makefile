.PHONY: all up down clean setup fclean

all: setup up

setup:
	@echo "Setting up Inception project..."
	@./scripts/setup.sh

up: setup
	@echo "Starting services..."
	docker compose --env-file srcs/.env -f docker-compose.yml up --build -d

down:
	docker compose --env-file srcs/.env -f docker-compose.yml down

clean:
	docker compose -f docker-compose.yml down -v --rmi all 2>/dev/null || true
	rm -f srcs/.env secrets/db_password.txt secrets/db_root_password.txt secrets/server.crt secrets/server.key

fclean: clean
	docker system prune -af
	docker volume prune -f
	sudo rm -rf /home/amema/data
