# Makefile for Symfony + Docker Compose deployment

ENV_FILE ?= .env.compose
COMPOSE=docker compose -f compose.yaml -f compose.prod.yaml

export $(shell grep -v '^#' $(ENV_FILE) | xargs)

PHP_CONTAINER=php

.PHONY: build up down restart logs deploy migrate cache-clear warmup assets

## Build the containers from scratch
build:
	@echo "🔧 Building containers with environment from $(ENV_FILE)..."
	$(COMPOSE) build --no-cache

## Start the stack
up:
	@echo "🚀 Starting stack using $(ENV_FILE)..."
	$(COMPOSE) up -d --wait

## Stop and clean up everything
down:
	@echo "🧹 Shutting down and removing containers, volumes, and network..."
	$(COMPOSE) down -v --remove-orphans

## Full restart
restart: down build up

## Show live logs from PHP container
logs:
	$(COMPOSE) logs -f $(PHP_CONTAINER)

## Run migrations inside container
migrate:
	@echo "📦 Running doctrine:migrations:migrate..."
	$(COMPOSE) exec $(PHP_CONTAINER) php bin/console doctrine:migrations:migrate --no-interaction

## Clear and warm up cache
cache-clear:
	@echo "🧹 Clearing cache..."
	$(COMPOSE) exec $(PHP_CONTAINER) php bin/console cache:clear --env=prod
	@echo "⚡️ Warming up cache..."
	$(COMPOSE) exec $(PHP_CONTAINER) php bin/console cache:warmup --env=prod

## Install assets (if you're using Webpack Encore, etc.)
assets:
	@echo "🎨 Installing assets..."
	$(COMPOSE) exec $(PHP_CONTAINER) php bin/console assets:install public --env=prod

## Full deploy sequence
deploy: down build up migrate cache-clear assets
	@echo "✅ Deployment complete at https://$${SERVER_NAME}"
