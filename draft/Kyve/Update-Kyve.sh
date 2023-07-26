#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function update() {
sudo apt update && sudo apt upgrade -y
}

logo
if [ -f $HOME/.sdd_Kyve_do_not_remove ]; then
  update
  logo
fi
