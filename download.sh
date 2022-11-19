#!/usr/bin/env bash

##
# make multiple copies of +workshop_download_item to download more than one mod.
##

appid=322300
workshop_item=378160973

mkdir $PWD/src

steamcmd +force_install_dir $PWD/src \
	+login anonymous \
	+app_update $appid \
	+workshop_download_item $appid $wordshop_item \
       	+quit
