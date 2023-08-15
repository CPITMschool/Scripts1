#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
 bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function update() {
  cd /root/lava
  git fetch --all
  git checkout v0.16.0
  make install
  lavad version --long | grep -e commit -e version
  systemctl restart lavad
}

if [ -f /root/.sdd_Lava_do_not_remove ]; then
  update
fi

logo
update

printGreen "Lava node оновлено"

cd ~
