#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

logo

printGreen "Оновлення ноди."

function update() {
    printGreen "Починаємо оновлення..."
    cd $HOME
    systemctl stop defund
    cd $HOME/defund
    git checkout v0.2.6
    make install
    systemctl restart defund
    cd $HOME
    printGreen "Оновлення завершено."
}

update
