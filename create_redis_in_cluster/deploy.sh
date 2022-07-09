#!/bin/bash
echo "--------------------------------------------------------------------------------------------------------------"
echo "             REDIS STACK DEPLOYMENT                                                                           "
echo "--------------------------------------------------------------------------------------------------------------"

export SENTINEL_HOSTNAME=$1 #manager
export REDIS_MASTER_HOSTNAME=$1 #manager
export REDIS_SLAVE_NODE1_HOSTNAME=$2 #worker1
export REDIS_SLAVE_NODE2_HOSTNAME=$3 #worker2

if [ -z $SENTINEL_HOSTNAME ] || [ -z $REDIS_MASTER_HOSTNAME ] || [ -z $REDIS_SLAVE_NODE1_HOSTNAME ]  || [ -z $REDIS_SLAVE_NODE2_HOSTNAME ] ; then
  echo "Status: Arguments missing. Cannot continue to build the stack. Missing SENTINEL_HOSTNAME, REDIS_MASTER_HOSTNAME, REDIS_SLAVE_NODE1_HOSTNAME, REDIS_SLAVE_NODE1_HOSTNAME" >&2
  exit 1;
fi


echo "1- Start to push on registry the redis docker image which can be used as master or slave in the stack..."
docker compose -f img_master_slave/master_slave_docker_compose.yaml build
docker compose -f img_master_slave/master_slave_docker_compose.yaml push
echo "(1)End to build and push redis image to registry."
echo "-------------------------------------------------------\n"

echo "2- Start to push on registry the redis docker image which will be used to build sentinel..."
docker compose -f img_sentinel/sentinel_docker_compose.yaml build
docker compose -f img_sentinel/sentinel_docker_compose.yaml push
echo "(2)End to build and push redis sentinel image to registry."
echo "-------------------------------------------------------\n"


echo "3- Start to push our python app example on the registry..."
docker compose -f img_pythonapp/app_docker_compose.yaml build
docker compose -f img_pythonapp/app_docker_compose.yaml push
echo "(3)End to push our python app example on the registry."
echo "-------------------------------------------------------\n"


echo "4- Start to deploy the stack..."
export SENTINEL_IP=`docker node inspect --format {{.Status.Addr}} $SENTINEL_HOSTNAME`
export REDIS_MASTER_IP=`docker node inspect --format {{.Status.Addr}} $REDIS_MASTER_HOSTNAME`

echo "Sentinel hostname and IP: $SENTINEL_HOSTNAME -  $SENTINEL_IP"
echo "Redis Master hostname and IP: $REDIS_MASTER_HOSTNAME - $REDIS_MASTER_IP"
echo "Redis slave 1 hostname: $REDIS_SLAVE_NODE1_HOSTNAME"
echo "Redis slave 2 hostname: $REDIS_SLAVE_NODE2_HOSTNAME"

docker stack deploy -c docker-compose.yaml stackredis
printf "(4)End to deploy the stack... Please wait until the services started\n\n\n"

sleep 3s

printf "Status: The stack deployment has been completed.\n\n"


docker service ls
printf "If all services replicas are not already deployed, please run << docker service ls >> to see if it now completed.\n"

echo "running on http://$REDIS_MASTER_HOSTNAME:38000"