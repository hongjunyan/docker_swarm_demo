docker stack rm stackredis
docker volume prune -f
docker network prune -f
docker image prune -af