#!/usr/bin/env bash

##
# make multiple copies of +workshop_download_item to download more than one mod.
##

clientappid=322330
serverappid=343050
mods=(
    378160973 # global pos
    1378549454
    758532836 # global pause
    375859599 # Health Info
    )
mkdir $PWD/src

steamcmd +force_install_dir $PWD/src \
    +login anonymous \
    +app_update $serverappid \
    +quit

for mod in "${mods[@]}"
do
    echo downloading item $mod
    steamcmd +force_install_dir $PWD/src \
        +login anonymous \
        +workshop_download_item $clientappid $mod \
        +quit
done
