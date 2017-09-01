#!/bin/bash

docker stop $(docker ps -a -q) || echo
docker rm -f -v $(docker ps -a -q) || echo
docker rmi -f $(docker images -q $1) || echo
