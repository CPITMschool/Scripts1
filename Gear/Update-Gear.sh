#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

logo

gear_path=$(find /root -name "gear" -type f)
gear_version=$($gear_path --version)
printGreen "Версія вашої ноди Gear - $gear_version"

printGreen "Актуальна версія для оновлення 0.3.1. Бажаєте оновити? (Y/N)"
read response

function update() {
    if [[ $response == "Y" || $response == "y" ]]; then
        echo "==================================================="
        printGreen "Розпочалось оновлення вашої ноди"
        echo "==================================================="
        cd
        sudo systemctl stop gear
        
        printGreen "Завантаження нової версії на ваш сервер"
       curl https://get.gear.rs/gear-v0.3.1-x86_64-unknown-linux-gnu.tar.xz | sudo tar -xJC /root


        sudo systemctl stop gear
        /root/gear purge-chain -y && sleep 3

        printGreen "Перезавантажуємо Gear."
        sudo systemctl start gear
        sleep 10

        sed -i "s/gear-node/gear/" "/etc/systemd/system/gear.service"

        sudo systemctl daemon-reload
        sudo systemctl stop gear

        cd /root/.local/share/gear/chains
        mkdir -p gear_staging_testnet_v6/network/

        sudo cp gear_staging_testnet_v6/network/secret_ed25519 gear_staging_testnet_v7/network/secret_ed25519 &>/dev/null

        sudo sed -i 's/telemetry\.postcapitalist\.io/telemetry.doubletop.io/g' /etc/systemd/system/gear.service

        sudo systemctl daemon-reload
        sudo systemctl restart gear && sleep 10

        gear_path=$(find /root -name "gear" -type f)
        updated_gear_version=$($gear_path --version)
        printGreen "Оновлення Gear до версії $updated_gear_version завершено."
        printGreen "Перевірити поточну версію вашої ноди ви можете командою - ./gear --version . "
    else
        printGreen "Оновлення Gear не виконано.Спробуйте ще раз."
    fi
}


update
