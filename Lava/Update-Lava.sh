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
  printGreen "Оновлюємо до версії v0.26.1 "
  echo ""
  sudo systemctl stop lavad

  export LAVA_BINARY=lavad

  cd || return
  rm -rf lava
  git clone https://github.com/lavanet/lava
  cd lava || return
  git checkout v0.26.1
  make install

  sudo systemctl start lavad
  
  printDelimiter
  printGreen "Переглянути журнал логів:         sudo journalctl -u lavad -f -o cat"
  printGreen "Переглянути статус синхронізації: lavad status 2>&1 | jq .SyncInfo"
  printGreen "Порти які використовує ваша нода: 17658,17657,17656,1760,17660,1790,1791,1717"
  printGreen "В журналі логів спочатку ви можете побачити помилку Connection is closed. Але за 5-10 секунд нода розпочне синхронізацію"
  printDelimiter
}

install
