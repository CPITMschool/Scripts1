#!/bin/bash

function logo() {
  curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh | bash
}

function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function install() {

read -p "Enter your Alchemy link (example: https://eth-goerli.alchemyapi.io/v2/secret): " ALCHEMY_KEY
sleep 1
echo 'export ALCHEMY_KEY='$ALCHEMY_KEY >> $HOME/.bash_profile

printGreen "Install dependencies"
sudo apt update
sudo apt install mc wget curl git htop net-tools unzip jq build-essential ncdu tmux -y

orintGreen "Install docker and docker compose"
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/StarkNet/docker-install.sh)

git clone https://github.com/eqlabs/pathfinder.git
cd $HOME/pathfinder || exit
git fetch
VER=$(curl https://api.github.com/repos/eqlabs/pathfinder/releases/latest -s | jq .name -r)
git checkout $VER

source $HOME/.bash_profile
echo "PATHFINDER_ETHEREUM_API_URL=$ALCHEMY_KEY" > pathfinder-var.env


docker compose pull
mkdir -p $HOME/pathfinder/pathfinder
chown -R 1000.1000 .
sleep 1
docker compose up -d

printDelimiter
printGreen "Перевірити роботу ноди ви можете на своєму Alchemy."
printGreen "Порт який використовує нода: 9645"
printDelimiter

}

logo
install
touch $HOME/.sdd_StarkNet_do_not_remove
logo
