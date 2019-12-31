#!/bin/bash

if [ -z "$1" ]
  then
    echo "Please specify first argument from which resource to copy"
    echo "e.g: ./deploy-static.sh carmeldev:/home/carmel/www/prod/vango-assistant assistant.vango.run" 
    exit
fi

if [ -z "$1" ]
  then
    echo "Please specify second argument to which folder to copy relative to sivan:/home/prod/"
    echo "e.g: ./deploy-static.sh carmeldev:/home/carmel/www/prod/vango-assistant assistant.vango.run" 
    exit
fi

rm /tmp/kl -rf
mkdir /tmp/kl
rsync -rvza carmeldev:/home/carmel/www/prod/$1/* /tmp/kl

destFolder=/home/carmel/www/prod/$2
folder=$(ssh sivan ls $destFolder 2>/dev/null)
echo $folder

if [ -z "$folder" ]; then
	echo "No folder on dest: $destFolder"
	echo "Aborting..."
	exit
else
	echo "Destination folder exist ($destFolder)"
fi

echo "rsync --delete -rvza /tmp/kl/* sivan:$destFolder"
read -r -p "Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        ;;
    *)
        exit
        ;;
esac

echo "confirmed"

rsync --delete -rvza /tmp/kl/* sivan:$destFolder


