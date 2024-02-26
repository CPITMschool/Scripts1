#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
  sudo systemctl stop babylond
  sudo systemctl disable babylond
  sudo rm /etc/systemd/system/babylond.service
  sudo systemctl daemon-reload
  rm -rf $HOME/.babylond 
  rm -rf babylon && sudo rm -rf $(which babylond) 
}

logo
delete

printGreen "Babylon node - видалено"
