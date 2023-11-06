#!/bin/bash

function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function install() {
  clear
  source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)

  printGreen "Введіть ім'я для вашої ноди(Наприклад:Oliver):"
  read -r NODE_MONIKER

  printGreen "Встановлення необхідних залежностей"
  sudo apt -q update
  sudo apt -qy install curl git jq lz4 build-essential
  sudo apt -qy upgrade

  printGreen "Встановлення Go"
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
  source $HOME/.bash_profile

  printGreen "Встановлення Lava"
  export LAVA_BINARY=lavad

  cd || return
  rm -rf lava
  git clone https://github.com/lavanet/lava
  cd lava || return
  git checkout v0.26.1
  make install

  lavad config keyring-backend test
  lavad config chain-id lava-testnet-2
  lavad init "$NODE_MONIKER" --chain-id lava-testnet-2

  curl -s https://raw.githubusercontent.com/lavanet/lava-config/main/testnet-2/genesis_json/genesis.json > $HOME/.lava/config/genesis.json
  curl -s https://snapshots-testnet.nodejumper.io/lava-testnet/addrbook.json > $HOME/.lava/config/addrbook.json

  sed -i.bak -e "s%proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:17658\"%" \
    -e "s%laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:17656\"%" \
    -e "s%laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:17657\"%" \
    -e "s%pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:1760\"%" \
    -e "s%prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":17660\"%" $HOME/.lava/config/config.toml

  sed -i.bak -e "s%node = \"tcp://localhost:26657\"%node = \"tcp://localhost:17657\"%" $HOME/.lava/config/client.toml

  sed -i.bak -e "s%localhost:9090%localhost:1790%" $HOME/.lava/config/app.toml
  sed -i.bak -e "s%address = \"localhost:9091\"%address = \"localhost:1791\"%" $HOME/.lava/config/app.toml
  sed -i.bak -e "s%address = \"tcp://localhost:1317\"%address = \"tcp://localhost:1717\"%" $HOME/.lava/config/app.toml

  PEERS=""
  sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.lava/config/config.toml

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

  sed -i -e 'bcast_mode = ".*"/bcast_mode = "sync"/g' $HOME/.lava/config/config.toml

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

  printGreen
