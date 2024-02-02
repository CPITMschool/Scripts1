#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
  sudo systemctl stop subspaced subspaced-farmer
  sudo systemctl disable subspaced subspaced-farmer
  sudo rm -rf ~/.local/share/subspace*
  sudo rm -rf /etc/systemd/system/subspace*
  sudo rm -rf /usr/local/bin/subspace*
}

if [ -f $HOME/.sdd_Subspace_do_not_remove ]; then
  delete
fi

logo
delete

printGreen "Subspace node видалено"
