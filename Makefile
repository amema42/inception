.PHONY: all up down clean

all: up

up:
	docker compose --env-file srcs/.env -f srcs/docker-compose.yml up --build -d

down:
	docker compose --env-file srcs/.env -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down -v --rmi all

