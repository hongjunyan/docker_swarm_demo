docker compose -f docker-compose.yaml -f monitor/docker-compose.yaml down --volumes
docker container prune -f
docker image prune -af
docker volume prune -f
docker network prune -f 