bash uninstall.sh

docker compose -f build_images.yaml build

docker compose -f docker-compose.yaml -f monitor/docker-compose.yaml -p redis-service up -d 

export REDIS_MASTER_IP=`docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis-service-master1-1`

docker container prune -f

docker compose -f docker-compose.yaml -f monitor/docker-compose.yaml -p redis-service up -d