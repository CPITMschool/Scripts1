#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
echo "-----------------------------------------------------------------------------"
sudo systemctl stop starknetd
sudo systemctl disable starknetd
sudo rm -rf $HOME/pathfinder/py
sudo rm -rf /etc/systemd/system/starknetd.service
rm -rf /usr/local/bin/pathfinder
echo "Нода успішно видалена"
echo "-----------------------------------------------------------------------------"
}

