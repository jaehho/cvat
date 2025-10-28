#!/bin/bash
export CVAT_HOST=cvat.jaehho.com

docker compose -f docker-compose.yml \
    -f docker-compose.settings_overlay.local.yml \
    up -d
