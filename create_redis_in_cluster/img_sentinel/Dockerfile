FROM redis:5

EXPOSE 26379

COPY ./sentinel.conf /etc/redis/sentinel.conf

RUN chown redis:redis /etc/redis/sentinel.conf

ENV REDIS_MASTER_NAME=mymaster \
    REDIS_MASTER_HOST=redis-master \
    REDIS_MASTER_PORT=6379 \
    SENTINEL_QUORUM=2 \
    SENTINEL_DOWN_AFTER=30000\
    SENTINEL_PARALLEL_SYNC=1 \
    SENTINEL_FAILOVER_TIMEOUT=180000

COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME /etc/redis

ENTRYPOINT ["entrypoint.sh"]