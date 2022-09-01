#!/bin/sh
sed -i "s/\$MASTER_HOST/$MASTER_HOST/g" /etc/redis/redis.conf
sed -i "s/\$MASTER_PORT/$MASTER_PORT/g" /etc/redis/redis.conf

# the guide for "if" usage: https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
if [ -z "$MASTER_HOST" ]
    then
        # In Master node, we disable replicaof
        sed -i "s/replicaof/\#replicaof/g" /etc/redis/redis.conf
fi
exec docker-entrypoint.sh redis-server /etc/redis/redis.conf