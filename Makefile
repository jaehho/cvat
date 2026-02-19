SHELL := /bin/bash
.SILENT:
.IGNORE:
.DEFAULT_GOAL := help

REPO_ROOT := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

## General
help: ## Show this help message
	echo "Available targets:"
	echo "=================="
	grep -E '(^[a-zA-Z_-]+:.*?## .*$$|^## )' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; \
		     /^## / {gsub("^## ", ""); print "\n\033[1;35m" $$0 "\033[0m"}; \
		     /^[a-zA-Z_-]+:/ {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

## CVAT lifecycle
CVAT_HOST := cvat.jaehho.com
COMPOSE_FILES := \
	-f docker-compose.yml \
	-f components/serverless/docker-compose.serverless.yml \
	-f docker-compose.settings_overlay.local.yml

export CVAT_HOST

.PHONY: up down build
up: ## Start CVAT services
	docker compose $(COMPOSE_FILES) up -d

down: ## Stop CVAT services
	docker compose $(COMPOSE_FILES) down

build: ## Build CVAT services
	docker compose $(COMPOSE_FILES) -f docker-compose.dev.yml build --pull

superuser: ## Create a CVAT superuser
	docker exec -it cvat_server bash -ic 'python3 ~/manage.py createsuperuser'

## Cloudflared tunnel (systemd)
CLOUDFLARED_SERVICE ?= cloudflared

.PHONY: cloudflared-status cloudflared-start cloudflared-stop cloudflared-restart
cloudflared-status: ## Show cloudflared tunnel service status (systemd)
	sudo systemctl status $(CLOUDFLARED_SERVICE) --no-pager

cloudflared-start: ## Start cloudflared tunnel service (systemd)
	sudo systemctl start $(CLOUDFLARED_SERVICE)

cloudflared-stop: ## Stop cloudflared tunnel service (systemd)
	sudo systemctl stop $(CLOUDFLARED_SERVICE)

cloudflared-restart: ## Restart cloudflared tunnel service (systemd)
	sudo systemctl restart $(CLOUDFLARED_SERVICE)

cloudflared-info: ## Show cloudflared tunnel information
	echo "Tunnel information for 'mililab':"
	echo "-------------------------------"
	cloudflared tunnel info mililab
	echo "Tunnel configuration:"
	echo "---------------------"
	cat /etc/cloudflared/config.yml
