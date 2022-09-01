# Redis Sentinel mode in one host by using WSL
這節講述如何在一台windows主機上，使用WSL + docker來模擬3台redis server(1 Master + 2 Replicas)，並使用sentinel來提高redis的高可用度。

# Step1: Run Redis with Sentinel


## Two Ways to run sentinel
- run with `redis-sentinel` command:
```
$> redis-sentinel /path/to/sentinel.conf
```
- run with `redis-server` command:
```
$> redis-sesrver /path/to/sentinel.conf --sentinel
```
Both ways work the same. 

## Some note for Sentinel
1. the `/path/to/sentine.conf` must be writeable, because Sentinel will rewrite the params when fail occur.
2. Sentinels by default run listening for connections to TCP port `26379`
3. At least "three" Sentinel instances for a robust deployment

## Set replication when add a new slave
```commnad
# In new slave node
$> redis-cli
redis> replicaof hostname_or_IP port
```

## Monitor redis with prometheus
- ref: https://github.com/deanwilson/docker-compose-prometheus/blob/main/README.md#introduction