#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
  sudo systemctl stop defundd && sudo systemctl disable defundd
  sudo rm -rf /etc/systemd/system/defundd
  sudo rm -rf /usr/local/bin/defundd
  sudo rm -rf $HOME/.defund
  sudo rm -rf $HOME/defund
}

if [ -f $HOME/.sdd_Defund_do_not_remove ]; then
  delete
fi

logo
delete

printGreen "DeFund node видалено"
