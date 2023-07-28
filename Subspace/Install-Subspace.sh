#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function install() {
echo "-----------------------------------------------------------------------------"

  sudo apt update && sudo apt install mc wget htop jq git -y
  curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/Install-Docker.sh | bash
  curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/install_ufw.sh | bash

  if [ ! $SUBSPACE_NODENAME ]; then
  echo -e "Введіть ім'я вашої ноди"
  line_1
  read SUBSPACE_NODENAME
  fi

  if [ ! $WALLET_ADDRESS ]; then
  echo -e "Введіть свою polkadot.js extension адресу"
  line_1
  read WALLET_ADDRESS
  fi

  export CHAIN="gemini-3e"
  export RELEASE="gemini-3e-2023-jul-03"

  mkdir -p $HOME/subspace_docker/
  sudo tee <<EOF >/dev/null $HOME/subspace_docker/docker-compose.yml
  version: "3.7"
  services:
    node:
      image: ghcr.io/subspace/node:$RELEASE
      volumes:
        - node-data:/var/subspace:rw
      ports:
        - "0.0.0.0:32333:30333"
        - "0.0.0.0:32433:30433"
      restart: unless-stopped
      command: [
        "--chain", "$CHAIN",
        "--base-path", "/var/subspace",
        "--execution", "wasm",
        "--blocks-pruning", "archive",
        "--state-pruning", "archive",
        "--port", "30333",
        "--unsafe-rpc-external",
        "--dsn-listen-on", "/ip4/0.0.0.0/tcp/30433",
        "--rpc-cors", "all",
        "--rpc-methods", "safe",
        "--dsn-disable-private-ips",
        "--no-private-ipv4",
        "--validator",
        "--name", "$SUBSPACE_NODENAME",
        "--telemetry-url", "wss://telemetry.subspace.network/submit 0",
        "--out-peers", "100"
      ]
      healthcheck:
        timeout: 5s
        interval: 30s
        retries: 5

    farmer:
      depends_on:
        - node
      image: ghcr.io/subspace/farmer:$RELEASE
      volumes:
        - farmer-data:/var/subspace:rw
      ports:
        - "0.0.0.0:32533:30533"
      restart: unless-stopped
      command: [
        "--base-path", "/var/subspace",
        "farm",
        "--disable-private-ips",
        "--node-rpc-url", "ws://node:9944",
        "--listen-on", "/ip4/0.0.0.0/tcp/30533",
        "--reward-address", "$WALLET_ADDRESS",
        "--plot-size", "100G"
      ]
  volumes:
    node-data:
    farmer-data:
EOF
  docker-compose -f $HOME/subspace_docker/docker-compose.yml up -d

}

logo
install
touch $HOME/.sdd_Subspace_do_not_remove
logo
