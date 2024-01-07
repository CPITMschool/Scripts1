#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
  rm $(which babylond)
  rm -rf babylon .babylond
  rm /etc/systemd/system/babylond.service
}

logo
delete

printGreen "Babylon node - видалено"
