#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function install() {
echo "-----------------------------------------------------------------------------"
if [ ! $ALCHEMY_KEY ]; then
	read -p "Введіть ваш HTTP (Приклад: https://eth-goerli.alchemyapi.io/v2/xZXxxxxxxxxxxc2q_bzxxxxxxxxxxWTN): " ALCHEMY_KEY
fi
echo 'Ваш ключ: ' $ALCHEMY_KEY
sleep 1
echo 'export ALCHEMY_KEY='$ALCHEMY_KEY >> $HOME/.bash_profile
echo "Завантажуємо софт"
echo "-----------------------------------------------------------------------------"
sudo apt update -y &>/dev/null
sudo apt install build-essential libssl-dev libffi-dev python3-dev screen git python3-pip python3.*-venv -y &>/dev/null
sudo apt-get install libgmp-dev -y &>/dev/null
pip3 install fastecdsa &>/dev/null
sudo apt-get install -y pkg-config &>/dev/null
curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/install_ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/install_rust.sh | bash &>/dev/null
rustup default nightly &>/dev/null
source $HOME/.cargo/env &>/dev/null
sleep 1
echo "Увесь необхідний софт завантажено"
echo "-----------------------------------------------------------------------------"
git clone --branch v0.1.8-alpha https://github.com/eqlabs/pathfinder.git &>/dev/null
cd pathfinder/py &>/dev/null
python3 -m venv .venv &>/dev/null
source .venv/bin/activate &>/dev/null
PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip &>/dev/null
PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt &>/dev/null
cargo build --release --bin pathfinder &>/dev/null
sleep 2
source $HOME/.bash_profile &>/dev/null
echo "Білд завершений успішно"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo tee <<EOF >/dev/null /etc/systemd/system/starknet.service
[Unit]
Description=StarkNet Node
After=network.target
[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/pathfinder/py
Environment=PATH="$HOME/pathfinder/py/.venv/bin:\$PATH"
ExecStart=$HOME/pathfinder/target/release/pathfinder --ethereum.url $ALCHEMY_KEY
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF
echo "Сервісні файли створені успішно"
echo "-----------------------------------------------------------------------------"
sudo systemctl restart systemd-journald &>/dev/null
sudo systemctl daemon-reload &>/dev/null
sudo systemctl enable starknet &>/dev/null
sudo systemctl restart starknet &>/dev/null
echo "Нода додана на автозавантаження на сервері, запущена"
echo "-----------------------------------------------------------------------------"
}

logo
install
touch $HOME/.sdd_StarkNet_do_not_remove
logo
