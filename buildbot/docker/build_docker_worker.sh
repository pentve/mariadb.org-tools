#!/bin/bash

# This script locally builds a Docker image,
# the purpose of which is to server as a
# Buildbot worker, using Dockerfile_<worker name>

script_dir="$(dirname "$0")"
pushd $script_dir > /dev/null

function print_usage {
    echo ""
    echo "Usage: $0 <worker name>"
    echo "Example: $0 ubuntu-worker"
    echo ""
    echo "Note: Dockerfile source is Dockerfile_<worker name>"
    echo ""
}

function clean_and_exit {
    echo Removing directory \"build_image_tmp\"
    rm -rf build_image_tmp # not parametrized to avoid accidents
    popd > /dev/null
    exit $1
}

if [[ $# -eq 0 ]] ; then
    echo "Error: missing parameter"
    print_usage
    popd > /dev/null
    exit 2
fi

worker_name=$1
build_dir=build_image_tmp
dockerfile_source=Dockerfile_$worker_name
dockerfile_target=$build_dir/worker/Dockerfile

if [ ! -f $dockerfile_source ]; then
    echo "Error: missing file \"$dockerfile_source\""
    print_usage
    popd > /dev/null
    exit 1
fi

echo Going to build Docker image \"$worker_name\" from \"$dockerfile_source\"

echo Creating directory \"$script_dir/$build_dir\"
mkdir -p $build_dir || { popd > /dev/null; exit 1; }

echo Fetching the generic Buildbot worker sources to \"$script_dir/$build_dir\"
curl -sL https://github.com/buildbot/buildbot/archive/master.tar.gz | tar --strip-components=1 -C $build_dir -xz || clean_and_exit 1

echo Replacing \"$dockerfile_target\" with \"$dockerfile_source\"
cp $dockerfile_source $build_dir/worker/Dockerfile || clean_and_exit 1

echo Building Docker image \"$worker_name\"
sudo docker build --no-cache $build_dir/worker -t $worker_name || clean_and_exit 1

echo Done
clean_and_exit 0
