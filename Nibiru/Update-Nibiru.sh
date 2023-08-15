#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

logo

nibid_version=$(nibid version)
printGreen "Версія вашої ноди Nibiru - $nibid_version"

printGreen "Актуальна версія для оновлення v0.19.2. Бажаєте оновити? (Y/N)"
read response

function update() {
    if [[ $response == "Y" || $response == "y" ]]; then
        cd
        git clone https://github.com/NibiruChain/nibiru
        cd nibiru
        git checkout v0.19.2
        make install
        
        updated_version=$(nibid version)
        printGreen "Оновлення до версії $updated_version завершено."
    else
        printGreen "Оновлення не виконано."
    fi
}

update
