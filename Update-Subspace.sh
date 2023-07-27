#!/bin/bash

function logo() {
bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function update() {
echo "-----------------------------------------------------------------------------"
function update_subspace {
  cd $HOME/subspace_docker/
  docker-compose down
  eof_docker_compose
  docker-compose pull
  docker-compose up -d
}

logo
if [ -f $HOME/.sdd_Subspace_do_not_remove ]; then
  update
  logo
fi