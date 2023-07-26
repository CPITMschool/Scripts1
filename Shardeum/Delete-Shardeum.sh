#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
reset
rm -f $HOME/.sdd_Shardeum_do_not_remove
cd $HOME/.shardeum
docker compose down
cd $HOME
rm -Rf $HOME/.shardeum
}

logo
if [ -f $HOME/.sdd_Shardeum_do_not_remove ]; then
  delete
  logo
fi
