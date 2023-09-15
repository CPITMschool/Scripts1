#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

printGreen "Оновлення пакетів сервера..." && sleep 1
sudo apt-get update &&
sudo apt-get install -y curl iptables build-essential git lz4 wget jq make gcc nano chrony \
sudo apt install -y make gcc jq curl git build-essential chrony unzip gzip

printGreen "Встановлюємо GO..." && sleep 1
if ! [ -x "$(command -v go)" ]; then
  source <(curl -s "https://raw.githubusercontent.com/nodejumper-org/cosmos-scripts/master/utils/go_install.sh")
  source $HOME/.bash_profile
fi
