#!/bin/sh
sed -i "s/\$SENTINEL_PORT/$SENTINEL_PORT/g" /etc/redis/sentinel.conf
sed -i "s/\$MASTER_NAME/$MASTER_NAME/g" /etc/redis/sentinel.conf
sed -i "s/\$MASTER_HOST/$MASTER_HOST/g" /etc/redis/sentinel.conf
sed -i "s/\$MASTER_PORT/$MASTER_PORT/g" /etc/redis/sentinel.conf
sed -i "s/\$QUORUM/$QUORUM/g" /etc/redis/sentinel.conf
sed -i "s/\$DOWN_AFTER_MS/$DOWN_AFTER_MS/g" /etc/redis/sentinel.conf
sed -i "s/\$FAILOVER_TIMEOUT/$FAILOVER_TIMEOUT/g" /etc/redis/sentinel.conf
sed -i "s/\$SENTINEL_PARALLEL_SYNC/$SENTINEL_PARALLEL_SYNC/g" /etc/redis/sentinel.conf
exec docker-entrypoint.sh redis-server /etc/redis/sentinel.conf --sentinel