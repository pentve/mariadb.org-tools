#!/bin/bash

# This script remotely builds a Docker image,
# the purpose of which is to server as a
# Buildbot worker, using Dockerfile_<worker name>

script_dir="$(dirname "$0")"

function print_usage {
    echo ""
    echo "Usage: $0 <login> <worker name>"
    echo "Example: $0 ubuntu@1.2.3.4 ubuntu-worker"
    echo ""
    echo "Note: Dockerfile source is Dockerfile_<worker name>"
    echo ""
}

function clean_and_exit {
    echo Removing directory \"build_image_remote_tmp\" from $login
    ssh $login 'rm -rf build_image_remote_tmp' # not parametrized to avoid accidents
    exit $1
}

if [[ $# -ne 2 ]] ; then
    echo "Error: missing parameters"
    echo ""
    print_usage
    exit 2
fi

login=$1
worker_name=$2

echo Creating directory \"build_image_remote_tmp\" at $login
ssh $login 'mkdir -p build_image_remote_tmp' || exit 1

echo Copying the sources at \"$script_dir\" to $login:~/build_image_remote_tmp/
scp -r $script_dir $login:~/build_image_remote_tmp/ || clean_and_exit 1

echo Removing Docker images with the name \"$worker_name\" from $login
ssh $login "sudo build_image_remote_tmp/remove_docker_images.sh $worker_name" || clean_and_exit 1

echo Building new Docker image \"$worker_name\" at $login
ssh $login "build_image_remote_tmp/build_docker_worker.sh $worker_name" || clean_and_exit 1

echo Done
clean_and_exit 0

