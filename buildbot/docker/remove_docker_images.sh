for i in $(docker images -a -q $1)
do
    echo removing image $i
    docker rmi -f $i
done
