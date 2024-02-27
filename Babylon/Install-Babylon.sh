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
  
  printGreen "Moniker - назва вашого валідатора, яка буде використовуватись в подальшому"
  printGreen "Введіть moniker для вашої ноди(Наприклад:Asapov):"
  read -r NODE_MONIKER

  printGreen "Оновлення сервера та встановлення GO"
  sudo apt update
  sudo apt install -y curl git jq lz4 build-essential unzip

  bash <(curl -s "https://raw.githubusercontent.com/nodejumper-org/cosmos-scripts/master/utils/go_install.sh")
  source ~/.bash_profile

  cd && rm -rf babylon
  git clone https://github.com/babylonchain/babylon
  cd babylon
  git checkout v0.8.3

  make install

  babylond config chain-id bbn-test-3
  babylond config keyring-backend test
  babylond config client node tcp://localhost:20657

  babylond init $NODE_MONIKER --chain-id bbn-test-3

  curl -L https://snapshots-testnet.nodejumper.io/babylon-testnet/genesis.json > $HOME/.babylond/config/genesis.json
  curl -L https://snapshots-testnet.nodejumper.io/babylon-testnet/addrbook.json > $HOME/.babylond/config/addrbook.json

  
  sed -i -e 's|^seeds *=.*|seeds = "49b4685f16670e784a0fe78f37cd37d56c7aff0e@3.14.89.82:26656,9cb1974618ddd541c9a4f4562b842b96ffaf1446@3.16.63.237:26656"|' $HOME/.babylond/config/config.toml


  sed -i -e 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.00001ubbn"|' $HOME/.babylond/config/app.toml


sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "17"|' \
  $HOME/.babylond/config/app.toml

sed -i 's|^network *=.*|network = "signet"|g' $HOME/.babylond/config/app.toml

sed -i -e "s%:1317%:20617%; s%:8080%:20680%; s%:9090%:20690%; s%:9091%:20691%; s%:8545%:20645%; s%:8546%:20646%; s%:6065%:20665%" $HOME/.babylond/config/app.toml
sed -i -e "s%:26658%:20658%; s%:26657%:20657%; s%:6060%:20660%; s%:26656%:20656%; s%:26660%:20661%" $HOME/.babylond/config/config.toml
sed -i.bak -e "s%:26657%:20657%g" $HOME/.babylond/config/client.toml

curl "https://snapshots-testnet.nodejumper.io/babylon-testnet/babylon-testnet_latest.tar.lz4" | lz4 -dc - | tar -xf - -C "$HOME/.babylond"

sudo tee /etc/systemd/system/babylond.service > /dev/null << EOF
[Unit]
Description=Babylon node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which babylond) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable babylond.service
source ~/.bash_profile

printGreen "Запускаємо ноду"
sudo systemctl start babylond.service

printDelimiter
printGreen "Переглянути журнал логів:         sudo journalctl -u babylond -f -o cat"
printGreen "Переглянути статус синхронізації: babylond status 2>&1 | jq .SyncInfo"
echo -e "\e[1;32mВаша нода Babylon займає наступний набір портів:\e[0m 20617,20680,20690,20691,20645,20646,20665,20658,20657,20656,20660"
printGreen "Запишіть значення портів, для можливості подальшого підселення космос нод, та уникнення конфліктів пов'язаних з портами"
echo "alias port_babylon='echo -e \"\e[1;32mВаша нода займає наступний набір портів:\e[0m 20617,20680,20690,20691,20645,20646,20665,20658,20657,20656,20660\"'" >> ~/.bash_profile
printGreen "Також якщо вам колись буде потрібно, введіть в терміналі port_babylon та ви знову побачите інформацію про список зайнятих портів"
printDelimiter
source ~/.bash_profile
}

install
