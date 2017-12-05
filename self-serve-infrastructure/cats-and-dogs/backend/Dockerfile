FROM redis

RUN apt-get update 
RUN apt-get install -y curl 
RUN apt-get install -y python3-pip
ADD /vote-db  /app

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 6379

CMD ["/app/start_redis.sh"]
