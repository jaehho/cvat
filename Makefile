.SILENT:
.IGNORE:

CVAT_HOST := cvat.jaehho.com
COMPOSE_FILES := \
	-f docker-compose.yml \
	-f components/serverless/docker-compose.serverless.yml \
	-f docker-compose.settings_overlay.local.yml

export CVAT_HOST

.PHONY: help
help: ## Show this help message
	echo "Available targets:"
	echo "=================="
	grep -E '(^[a-zA-Z_-]+:.*?## .*$$|^## )' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; \
		     /^## / {gsub("^## ", ""); print "\n\033[1;35m" $$0 "\033[0m"}; \
		     /^[a-zA-Z_-]+:/ {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

## CVAT lifecycle
.PHONY: up down build
up: ## Start CVAT services
	docker compose $(COMPOSE_FILES) up -d

down: ## Stop CVAT services
	docker compose $(COMPOSE_FILES) down

build: ## Build CVAT services
	docker compose $(COMPOSE_FILES) -f docker-compose.dev.yml build

superuser: ## Create a CVAT superuser
	docker exec -it cvat_server bash -ic 'python3 ~/manage.py createsuperuser'
