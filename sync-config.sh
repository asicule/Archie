#!/bin/sh

USER=$1
while [ -z "$USER" ]; do
    echo "Please enter a username: "
    read USER
done || exit 1

HOME=/home/$USER

rsync -avh --delete ./script/* target:/script/ && \
rsync -auv --exclude-from="./.syncignore" target:$HOME/ ./user && \
rsync ./user target:$HOME
