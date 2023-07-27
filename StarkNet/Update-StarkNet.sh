#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function update() {
echo "-----------------------------------------------------------------------------"
echo "Завантаження залежностей"
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/Install-Docker.sh) &>/dev/null
echo "-----------------------------------------------------------------------------"
echo "Оновлюємо репозиторій"
echo "-----------------------------------------------------------------------------"
cd $HOME/pathfinder
git fetch
git checkout `curl https://api.github.com/repos/eqlabs/pathfinder/releases/latest -s | jq .name -r`
echo "-----------------------------------------------------------------------------"
echo "Зупиняємо стару версію StarkNet, запущену через systemd"
echo "-----------------------------------------------------------------------------"
sudo systemctl stop starknet &>/dev/null
sudo systemctl disable starknet &>/dev/null
rm -rf $HOME/pathfinder/py/.venv &>/dev/null
echo "-----------------------------------------------------------------------------"
echo "Створюємо env файл зі змінною Alchemy або infura"
echo "-----------------------------------------------------------------------------"
source $HOME/.bash_profile
echo "PATHFINDER_ETHEREUM_API_URL=$ALCHEMY_KEY" > pathfinder-var.env
echo "-----------------------------------------------------------------------------"
echo "Завантажуємо останню версію docker image"
docker-compose pull
echo "Завантажили, переходимо до запуску"
echo "-----------------------------------------------------------------------------"
mkdir -p $HOME/pathfinder/pathfinder
chown -R 1000.1000 .
sleep 1
docker-compose up -d
echo "Нода оновлена і запущена"
echo "-----------------------------------------------------------------------------"
}

logo
if [ -f $HOME/.sdd_StarkNet_do_not_remove ]; then
  update
  logo
fi
