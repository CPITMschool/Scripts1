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
  printGreen "Оновлюємо Lava"
  echo ""
  sed -i 's/laddr = "tcp:\/\/0\.0\.0\.0:26656"/laddr = "tcp:\/\/0\.0\.0\.0:24656"/' /root/.lava/config/config.toml
  sed -i 's/address = "localhost:9091"/address = "localhost:9191"/' /root/.lava/config/app.toml
  sudo systemctl stop lavad

  export LAVA_BINARY=lavad

  cd || return
  rm -rf lava
  git clone https://github.com/lavanet/lava
  cd lava || return
  git checkout v0.30.2
  make install

  sudo systemctl start lavad
  sleep 2
  printGreen "Версія вашої ноди:"
  lavad version
  echo ""
  
  printDelimiter
  printGreen "Переглянути журнал логів:         sudo journalctl -u lavad -f -o cat"
  printGreen "Переглянути статус синхронізації: lavad status 2>&1 | jq .SyncInfo"
  printGreen "В журналі логів спочатку ви можете побачити помилку Connection is closed. Але за 5-10 секунд нода розпочне синхронізацію"
  printDelimiter
}

install
