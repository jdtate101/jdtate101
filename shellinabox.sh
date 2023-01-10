#!/bin/zsh
cd /Users/jtate/Documents/docker/compose/shellinabox
docker-compose stop
docker-compose rm  -f
docker-compose pull
docker-compose up -d
exit
