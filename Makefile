# Makefile for Symfony + Docker Compose deployment

ENV_FILE=.env.compose
COMPOSE=docker compose -f compose.yaml -f compose.prod.yaml

export $(shell grep -v '^#' $(ENV_FILE) | xargs)

.PHONY: build up down restart logs

## Build the containers from scratch with env vars loaded
build:
	@echo "🔧 Building containers with environment from $(ENV_FILE)..."
	$(COMPOSE) build --no-cache

## Start the stack with --wait and env vars loaded
up:
	@echo "🚀 Starting stack using $(ENV_FILE)..."
	$(COMPOSE) up -d --wait

## Stop and clean everything
down:
	@echo "🧹 Shutting down and removing containers, volumes, and network..."
	$(COMPOSE) down -v --remove-orphans

## Restart clean
restart: down build up

## View PHP container logs
logs:
	$(COMPOSE) logs -f php

## One-liner to deploy fully
deploy: down build up
	@echo "✅ Deployment complete at https://$${SERVER_NAME}"
