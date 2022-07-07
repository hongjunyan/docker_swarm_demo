FROM redis:5

COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME /etc/redis

ENTRYPOINT ["entrypoint.sh"]