.PHONY: all up down

all: up

up:
	docker-compose --env-file srcs/.env -f srcs/docker-compose.yml up --build -d

down:
	docker-compose --env-file srcs/.env -f srcs/docker-compose.yml down

