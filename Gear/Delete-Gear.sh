#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
sudo systemctl stop gear
sudo systemctl disable gear
sudo systemctl disable gear
sudo rm -r /root/.local/share/gear
sudo rm -r /root/gear
}

logo
delete

printGreen "Gear node видалено"