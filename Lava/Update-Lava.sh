#!/bin/bash

function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function backup_files() {
    source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
    printGreen "Копіюємо бекап файли ноди Lava в папку /root/BACKUPNODES/Lava backup" && sleep 3
    backup_dir="$HOME/BACKUPNODES"
    mkdir -p "$backup_dir"
    cp "$HOME/.lava/data/priv_validator_state.json" "$backup_dir/Lava backup/"
    cp "$HOME/.lava/config/node_key.json" "$backup_dir/Lava backup/"
    cp "$HOME/.lava/config/priv_validator_key.json" "$backup_dir/Lava backup/" 
    echo "Збережено: $lava_file_to_copy" && sleep 3
}

function remove_node() {
    printDelimiter
    printGreen "Видаляємо застарілу версію Lava" && sleep 3
    printDelimiter
    sudo systemctl stop lavad
    sudo systemctl disable lavad
    sudo rm -rf "$HOME/.lava"
    sudo rm -rf "$HOME/lava"
    sudo rm -rf "$HOME/lavad"
    sudo rm -rf /etc/systemd/system/lavad.service
    sudo rm -rf /usr/local/bin/lavad
    sudo systemctl daemon-reload
    printDelimiter
    printGreen "Через декілька секунд, розпочнеться звичайний процес встановлення ноди" && sleep 3
    printDelimiter
}

function install() {
clear
source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)


printGreen "Введіть ім'я для вашої ноди:"
read -r MONIKER

printGreen "Встановлення необхідних залежностей"
sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade

printGreen "Встановлення Go"
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.20.8.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)

printGreen "Встановлення Lava"
export LAVA_BINARY=lavad

cd || return
rm -rf lava
git clone https://github.com/lavanet/lava
cd lava || return
git checkout v0.25.2
make install

lavad config keyring-backend test
lavad config chain-id $CHAIN_ID
lavad init $MONIKER --chain-id lava-testnet-2

curl -s https://raw.githubusercontent.com/lavanet/lava-config/main/testnet-2/genesis_json/genesis.json > $HOME/.lava/config/genesis.json
curl -s https://snapshots-testnet.nodejumper.io/lava-testnet/addrbook.json > $HOME/.lava/config/addrbook.json

sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:14458\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:14457\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:14460\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:14456\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":14466\"%" $HOME/.lava/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:14417\"%; s%^address = \":8080\"%address = \":14480\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:14490\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:14491\"%; s%:8545%:14445%; s%:8546%:14446%; s%:6065%:14465%" $HOME/.lava/config/app.toml

sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.lava/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.lava/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.lava/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 0|g' $HOME/.lava/config/app.toml

sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.025ulava"|g' $HOME/.lava/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.lava/config/config.toml

sed -i \
  -e 's/timeout_commit = ".*"/timeout_commit = "30s"/g' \
  -e 's/timeout_propose = ".*"/timeout_propose = "1s"/g' \
  -e 's/timeout_precommit = ".*"/timeout_precommit = "1s"/g' \
  -e 's/timeout_precommit_delta = ".*"/timeout_precommit_delta = "500ms"/g' \
  -e 's/timeout_prevote = ".*"/timeout_prevote = "1s"/g' \
  -e 's/timeout_prevote_delta = ".*"/timeout_prevote_delta = "500ms"/g' \
  -e 's/timeout_propose_delta = ".*"/timeout_propose_delta = "500ms"/g' \
  -e 's/skip_timeout_commit = ".*"/skip_timeout_commit = false/g' \
  -e 's/seeds = ".*"/seeds = "3a445bfdbe2d0c8ee82461633aa3af31bc2b4dc0@testnet2-seed-node.lavanet.xyz:26656,e593c7a9ca61f5616119d6beb5bd8ef5dd28d62d@testnet2-seed-node2.lavanet.xyz:26656"/g' \
  $HOME/.lava/config/config.toml
sed -i -e 's/broadcast-mode = ".*"/broadcast-mode = "sync"/g' $HOME/.lava/config/config.toml

sudo tee /etc/systemd/system/lavad.service > /dev/null << EOF
[Unit]
Description=Lava Network Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which lavad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

lavad tendermint unsafe-reset-all --home $HOME/.lava --keep-addr-book
printGreen "Завантажуємо снепшот для прискорення синхронізації ноди"
SNAP_NAME=$(curl -s https://snapshots-testnet.nodejumper.io/lava-testnet/info.json | jq -r .fileName)
curl "https://snapshots-testnet.nodejumper.io/lava-testnet/${SNAP_NAME}" | lz4 -dc - | tar -xf - -C "$HOME/.lava"
printGreen "Запускаємо ноду"
sudo systemctl daemon-reload
sudo systemctl enable lavad
sudo systemctl start lavad

printDelimiter
printGreen "Переглянути журнал логів:         sudo journalctl -u lavad -f -o cat"
printGreen "Переглянути статус синхронізації: lavad status 2>&1 | jq .SyncInfo"
printGreen "Порти які використовує ваша нода: 14458,14457,14460,14456,14466,14417,14480,14490,14491"
printGreen "В журналі логів спочатку ви можете побачити помилку Connection is closed. Але за 5-10 секунд нода розпочне синхронізацію"
printDelimiter

}

function restore_files() {
    printGreen "Переносимо бекап файли в нову версію ноди Lava" && sleep 3
    printGreen "Бекап файли Lava перенесено" && sleep 2 
    printGreen "Вам залишилось тільки відновити ваш гаманець за допомогою мнемонічної фрази, командою: lavad keys add wallet --recover"
    restore_dir="$HOME/BACKUPNODES"
    cp "$restore_dir/Lava backup/priv_validator_state.json" "$HOME/.lava/data/"
    cp "$restore_dir/Lava backup/node_key.json" "$HOME/.lava/config/"
    cp "$restore_dir/Lava backup/priv_validator_key.json" "$HOME/.lava/config/"
}

backup_files
remove_node
install
restore_files
