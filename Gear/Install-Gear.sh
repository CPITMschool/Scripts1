#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

logo

if [ -f "$HOME/.gear_port" ]; then
    PORT=$(cat "$HOME/.gear_port")
else
    if ss -tuln | grep -q ':31333\b'; then
        PORT=31334
    else
        PORT=31333
    fi
    echo "$PORT" > "$HOME/.gear_port"
fi

if [ -z "$NODENAME_GEAR" ]; then
    echo -e "\e[1m\e[32mВведіть ім'я для вашої ноди (тільки букви та цифри):\e[0m"
    read -p "" NODENAME_GEAR
    echo 'export NODENAME='"$NODENAME_GEAR" >> "$HOME"/.profile
fi
printGreen "Ім'я вашої ноди: $NODENAME_GEAR"
sleep 1
echo "==================================================="
printGreen "Розпочалось встановлення Gear"
echo "==================================================="

function install() {
    sudo apt update
    sudo apt install ufw -y
    sudo ufw allow 22:65535/tcp
    sudo ufw allow 22:65535/udp
    sudo ufw deny out from any to 10.0.0.0/8
    #sudo ufw deny out from any to 172.16.0.0/12
    sudo ufw deny out from any to 192.168.0.0/16
    sudo ufw deny out from any to 100.64.0.0/10
    sudo ufw deny out from any to 198.18.0.0/15
    sudo ufw deny out from any to 169.254.0.0/16
    sudo ufw --force enable

    sudo apt update
    sudo apt install curl make clang pkg-config libssl-dev build-essential git mc jq unzip wget -y
    sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env
    sleep 1
    sudo apt install --fix-broken -y &>/dev/null
    sudo apt install git mc clang curl jq htop net-tools libssl-dev llvm libudev-dev -y &>/dev/null
    source $HOME/.profile &>/dev/null
    source $HOME/.bashrc &>/dev/null
    source $HOME/.cargo/env &>/dev/null
    sleep 1

    wget https://get.gear.rs/gear-v0.2.1-x86_64-unknown-linux-gnu.tar.xz &>/dev/null
    tar xvf gear-v0.2.1-x86_64-unknown-linux-gnu.tar.xz &>/dev/null
    rm gear-v0.2.1-x86_64-unknown-linux-gnu.tar.xz &>/dev/null
    chmod +x $HOME/gear &>/dev/null

    sudo tee /etc/systemd/journald.conf >/dev/null << EOF
Storage=persistent
EOF

    sudo tee /etc/systemd/system/gear.service >/dev/null << EOF
[Unit]
Description=Gear Node
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME
ExecStart=$HOME/gear \
        --name $NODENAME_GEAR \
        --execution wasm \
        --port $PORT \
        --telemetry-url 'ws://telemetry-backend-shard.gear-tech.io:32001/submit 0' \
        --telemetry-url 'wss://telemetry.postcapitalist.io/submit 0'
Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl restart systemd-journald &>/dev/null
    sudo systemctl daemon-reload &>/dev/null
    sudo systemctl enable gear &>/dev/null
    sudo systemctl restart gear &>/dev/null

    echo "==================================================="
    printGreen "Встановлення пройшло успішно"
    echo "==================================================="
    echo ""
    echo "Корисні команди:"
    printGreen "Перевірка журналу логів: journalctl -n 100 -f -u gear"
    printGreen "Перевірка версії ноди: ./gear --version"
    printGreen "Порт який використовується вашою нодою: $PORT"
}

install
