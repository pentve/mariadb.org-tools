#!/bin/bash

docker stop $(docker ps -a -q)
docker rm -f -v $(docker ps -a -q)
docker rmi -f $(docker images -q $1)
