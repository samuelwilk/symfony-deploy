# Makefile for Symfony + Docker Compose deployment

# Default environment config
ENV ?= dev
ENV_FILE ?= .env.compose
PHP_CONTAINER=php

ifeq ($(ENV),prod)
	COMPOSE=docker compose -f compose.yaml -f compose.prod.yaml
else
	COMPOSE=docker compose -f compose.yaml
endif

# Export env vars to shell
export $(shell grep -v '^#' $(ENV_FILE) | xargs)

.PHONY: build up down restart logs deploy migrate cache-clear warmup assets release current

## 🔧 Build the containers from scratch
build:
	@echo "🔧 Building containers for $(ENV) with $(ENV_FILE)..."
	$(COMPOSE) build --no-cache

## 🚀 Start the stack
up:
	@echo "🚀 Starting containers for $(ENV) with $(ENV_FILE)..."
	$(COMPOSE) up -d --wait

## 🧹 Stop and clean up everything
down:
	@echo "🧹 Stopping and removing containers, volumes, and network..."
	$(COMPOSE) down -v --remove-orphans

## ♻️ Full restart
restart: down build up

## 📺 Show live logs from PHP container
logs:
	$(COMPOSE) logs -f $(PHP_CONTAINER)

## 📦 Run migrations inside container
migrate:
	@echo "📦 Running doctrine:migrations:migrate..."
	$(COMPOSE) exec $(PHP_CONTAINER) php bin/console doctrine:migrations:migrate --no-interaction

## 🔥 Clear and warm up cache
cache-clear:
	@echo "🧹 Clearing cache..."
	$(COMPOSE) exec $(PHP_CONTAINER) php bin/console cache:clear --env=$(ENV)
	@echo "⚡️ Warming up cache..."
	$(COMPOSE) exec $(PHP_CONTAINER) php bin/console cache:warmup --env=$(ENV)

## 🎨 Install assets
assets:
	@echo "🎨 Installing assets..."
	$(COMPOSE) exec $(PHP_CONTAINER) php bin/console assets:install public --env=$(ENV)

## 🚢 Full deploy sequence (clean + up + migrate + warm cache + assets)
deploy: down build up migrate cache-clear assets
	@echo "✅ Deployment complete at https://$${SERVER_NAME}"

## 🔁 Switch to latest release (manual zero-downtime step placeholder)
release:
	@echo "🪄 TODO: Add symlink swap + cleanup for zero-downtime deployment"

## 👁 View current release path
current:
	@echo "🔎 Current release directory is: $(shell readlink current || echo '<not set>')"
