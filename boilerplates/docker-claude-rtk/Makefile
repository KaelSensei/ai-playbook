.PHONY: help build shell claude gain doctor rebuild down clean

UID := $(shell id -u 2>/dev/null || echo 1000)
GID := $(shell id -g 2>/dev/null || echo 1000)
COMPOSE_ENV := USER_UID=$(UID) USER_GID=$(GID)

help:
	@echo "Targets:"
	@echo "  make build     Build the image"
	@echo "  make shell     Drop into the container (bash)"
	@echo "  make claude    Run 'claude' inside the container"
	@echo "  make gain      Show RTK token savings stats"
	@echo "  make doctor    Run 'claude doctor'"
	@echo "  make rebuild   Force rebuild without cache"
	@echo "  make down      Stop and remove the container"
	@echo "  make clean     Remove container + volumes (loses Claude login!)"

build:
	$(COMPOSE_ENV) docker compose build

shell: build
	$(COMPOSE_ENV) docker compose run --rm claude bash

claude: build
	$(COMPOSE_ENV) docker compose run --rm claude claude

gain:
	$(COMPOSE_ENV) docker compose run --rm claude rtk gain

doctor:
	$(COMPOSE_ENV) docker compose run --rm claude claude doctor

rebuild:
	$(COMPOSE_ENV) docker compose build --no-cache

down:
	docker compose down

clean:
	docker compose down -v
