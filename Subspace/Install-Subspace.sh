#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

logo

function install() {
printGreen "Розпочалось встановлення Gemini 3g v0.7.4"
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi

read -p "Введіть вашу адресу гаманця: " SUBSPACE_WALLET
echo -e "\e[32mВаша адреса:\e[39m $SUBSPACE_WALLET"
read -p "Введіть ваш moniker без лишніх знаків . @ і т.д: " SUBSPACE_NODENAME

SUBSPACE_FARM_PATH=${SUBSPACE_FARM_PATH:-$HOME/.local/share/subspace-farmer}
SUBSPACE_NODE_PATH=${SUBSPACE_NODE_PATH:-$HOME/.local/share/subspace-node}

echo "Введіть розмір plot size (стандартно -  '2.0 GB', натисніть Enter, щоб залишити це значення) "
read -p " Наприклад: 500GB ; Бажаний розмір plot size: " PLOT_SIZE
PLOT_SIZE=${PLOT_SIZE:-2GB}
echo -e "\e[32mВаш plot size:\e[39m $PLOT_SIZE"

sudo mkdir -p $SUBSPACE_FARM_PATH
sudo mkdir -p $SUBSPACE_NODE_PATH

sudo apt update && sudo apt install ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y
cd $HOME
rm -rf subspace-node subspace-farmer
wget -O subspace-node https://github.com/subspace/subspace/releases/download/gemini-3h-2024-jan-31-2/subspace-node-ubuntu-x86_64-skylake-gemini-3h-2024-jan-31-2
wget -O subspace-farmer https://github.com/subspace/subspace/releases/download/gemini-3h-2024-jan-31-2/subspace-farmer-ubuntu-x86_64-skylake-gemini-3h-2024-jan-31-2
sudo chmod +x subspace-node subspace-farmer 
sudo mv subspace-node /usr/local/bin/
sudo mv subspace-farmer /usr/local/bin/

sudo systemctl stop subspaced subspaced-farmer &>/dev/null
sudo rm -rf $HOME/.local/share/subspace*

sleep 1

echo "[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/subspace-node run --base-path \"$SUBSPACE_NODE_PATH\" --chain gemini-3h --blocks-pruning 256 --state-pruning archive-canonical --farmer --name $SUBSPACE_NODENAME
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/subspaced.service


echo "[Unit]
Description=Subspaced Farm
After=network.target

[Service]
User=$USER
Type=simple
TimeoutStartSec=infinity
ExecStartPre=/usr/bin/sleep 60
ExecStart=/usr/local/bin/subspace-farmer farm --reward-address $SUBSPACE_WALLET path=$SUBSPACE_FARM_PATH,size=\"$PLOT_SIZE\"
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/subspaced-farmer.service


sudo mv $HOME/subspaced.service /etc/systemd/system/
sudo mv $HOME/subspaced-farmer.service /etc/systemd/system/
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced subspaced-farmer
sudo systemctl restart subspaced
sleep 20
sudo systemctl restart subspaced-farmer


if [[ `service subspaced status | grep active` =~ "running" ]]; then
echo ""
  echo "=================================================="
  printGreen "Subspace Gemini 3h успішно встановлено"
  echo ""
  printGreen "Корисні команди:"
  echo "Перевірити статус ноди - systemctl status subspaced"
  echo "Журнал логів - journalctl -u subspaced -f -o cat"
  echo "Журнал логів farmer - journalctl -u subspaced-farmer -f -o cat"
  echo "=================================================="
  echo ""
else
  printGreen "Нода Subspace не встановлено, спробуйте встановити ще раз."
fi

}

install
touch $HOME/.sdd_Subspace_do_not_remove
