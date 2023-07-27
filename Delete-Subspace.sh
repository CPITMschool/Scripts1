#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
echo "-----------------------------------------------------------------------------"
sudo systemctl stop subspaced 
sudo systemctl disable subspaced
sudo rm -rf $HOME/.local/share/subspace*
sudo rm -rf /etc/systemd/system/subspace*
sudo rm -rf /usr/local/bin/subspace*
}

logo
if [ -f $HOME/.sdd_Subspace_do_not_remove ]; then
  delete
  logo
fi