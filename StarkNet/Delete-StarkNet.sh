#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
 docker stop pathfinder-starknet-node-1
 docker rm pathfinder-starknet-node-1
 rm -rf /root/pathfinder/pathfinder/
}

if [ -f $HOME/.sdd_StarkNet_do_not_remove ]; then
  delete
fi

logo
delete

printGreen "StarkNet node видалено"

