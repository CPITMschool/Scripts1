#!/bin/bash

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}
  sudo systemctl stop lavad
  sudo systemctl disable lavad
  sudo rm -rf $HOME/.lava
  sudo rm -rf $HOME/lavad
  sudo rm -rf /etc/systemd/system/lavad.service
  sudo rm -rf /usr/local/bin/lavad
  sudo systemctl daemon-reload
}

if [ -f $HOME/.sdd_Lava_do_not_remove ]; then
  delete
fi

logo
printGreen "Lava node видалено"
