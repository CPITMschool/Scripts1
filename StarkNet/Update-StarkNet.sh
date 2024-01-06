#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function update() {
clear
logo
printGreen "Завантаження залежностей"
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/Install-Docker.sh) &>/dev/null
printGreen "Оновлюємо репозиторій"
cd $HOME/pathfinder
git fetch origin https://github.com/eqlabs/pathfinder.git refs/tags/v0.10.2-apikey
git checkout FETCH_HEAD
printGreen "Зупиняємо стару версію StarkNet"
sudo systemctl stop starknet &>/dev/null
sudo systemctl disable starknet &>/dev/null
rm -rf $HOME/pathfinder/py/.venv &>/dev/null
printGreen "Створюємо env файл зі змінною Alchemy або infura"
source $HOME/.bash_profile
echo "PATHFINDER_ETHEREUM_API_URL=$ALCHEMY_KEY" > pathfinder-var.env
printGreen "Завантажуємо останню версію docker image"
docker-compose pull
printGreen "Завантажили, переходимо до запуску"
mkdir -p $HOME/pathfinder/pathfinder
chown -R 1000.1000 .
sleep 1
docker-compose up -d
echo ""
echo "==========================================="
printGreen  "Нода оновлена і запущена"
printGreen "Перевірити версію ноди: docker exec -it pathfinder-starknet-node-1 pathfinder -V"
printGreen "Або ж , якщо у вас назва контейнеру інша, тоді скористайтесь командою: docker exec -it pathfinder_starknet-node_1 pathfinder -V"
echo "==========================================="
}
update
