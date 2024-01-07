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

  cd $HOME
  rm -rf dymension
  git clone https://github.com/dymensionxyz/dymension
  cd dymension
  git checkout v2.0.0-alpha.7
  make install

  dymd config chain-id froopyland_100-1
  dymd config keyring-backend test
  dymd init $NODE_MONIKER --chain-id froopyland_100-1

  curl -L https://snapshots-testnet.nodejumper.io/dymension-testnet/genesis.json > $HOME/.dymension/config/genesis.json
  curl -L https://snapshots-testnet.nodejumper.io/dymension-testnet/addrbook.json > $HOME/.dymension/config/addrbook.json

  sed -i \
  -e 's|^seeds *=.*|seeds = "ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@testnet-seeds.polkachu.com,92308bad858b8886e102009bbb45994d57af44e7@rpc-t.dymension.nodestake.top:666,284313184f63d9f06b218a67a0e2de126b64258d@seeds.silknodes.io:26157"|' \
  -e 's|^peers *=.*|peers = ""|' \
  $HOME/.dymension/config/config.toml

 
  sed -i -e 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.01udym"|' $HOME/.dymension/config/app.toml


  sed -i \
    -e 's|^pruning *=.*|pruning = "custom"|' \
    -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
    -e 's|^pruning-interval *=.*|pruning-interval = "17"|' \
    $HOME/.dymension/config/app.toml

  sed -i.bak -e "s%:1317%:2017%g; 
  s%:8080%:8780%g;
  s%:9090%:9790%g;
  s%:9091%:9791%g;
  s%:8545%:9245%g;
  s%:8546%:9246%g;
  s%:6065%:6765%g" $HOME/.dymension/config/app.toml	
  sed -i.bak -e "s%:26658%:33658%g;
  s%:26657%:33657%g;
  s%:6060%:6760%g;
  s%tcp://0.0.0.0:26656%tcp://0.0.0.0:33656%g;
  s%:26660%:33660%g" $HOME/.dymension/config/config.toml
  sed -i.bak -e "s%:26657%:33657%g" $HOME/.dymension/config/client.toml


  curl "https://snapshots-testnet.nodejumper.io/dymension-testnet/dymension-testnet_latest.tar.lz4" | lz4 -dc - | tar -xf - -C "$HOME/.dymension"


  sudo tee /etc/systemd/system/dymd.service > /dev/null << EOF
  [Unit]
  Description=Dymension node service
  After=network-online.target
  [Service]
  User=$USER
  ExecStart=$(which dymd) start
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=65535
  [Install]
  WantedBy=multi-user.target
  EOF
  sudo systemctl daemon-reload
  sudo systemctl enable dymd.service
  
  printDelimiter
  printGreen "Переглянути журнал логів:         sudo journalctl -u dymd -f -o cat"
  printGreen "Переглянути статус синхронізації: dymd status 2>&1 | jq .SyncInfo"
  printGreen "Обов'язково зробіть бекап вашого priv_validator_key.json, збережіть файл та скопіюйте в текстовому варіанті командою:
  printGreen "                                                                                                            cat $HOME/.dymension/config/priv_validator_key.json"
  printDelimiter
}

install
