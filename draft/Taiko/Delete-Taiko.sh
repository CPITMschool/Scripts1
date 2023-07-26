#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
reset
rm -f $HOME/.sdd_Taiko_do_not_remove
cd $HOME/simple-taiko-node
sudo docker-compose down
cd $HOME
rm -f .env
rm -rf simple-taiko-node
cd $HOME
}

logo
if [ -f $HOME/.sdd_Taiko_do_not_remove ]; then
  delete
  logo
fi
