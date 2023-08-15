#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\033[1;32m${1}\033[0m"
}

logo

VERSION=$(awk '
    /flags/ {
        if (/lm/&&/cmov/&&/cx8/&&/fpu/&&/fxsr/&&/mmx/&&/syscall/&&/sse2/) level = 1
        if (level == 1 && /cx16/&&/lahf/&&/popcnt/&&/sse4_1/&&/sse4_2/&&/ssse3/) level = 2
        if (level == 2 && /avx/&&/avx2/&&/bmi1/&&/bmi2/&&/f16c/&&/fma/&&/abm/&&/movbe/&&/xsave/) level = 3
        if (level == 3 && /avx512f/&&/avx512bw/&&/avx512cd/&&/avx512dq/&&/avx512vl/) level = 4
        if (level > 0) { print level; exit level + 1 }
        exit 1
    }
' /proc/cpuinfo)

if [[ $VERSION -ne 2 && $VERSION -ne 3 ]]; then
    printGreen "Our script doesn't support your processor"
    exit
fi

function update() {
    echo "-----------------------------------------------------------------------------"
    sudo systemctl stop subspaced

    cd "$HOME" || return
    wget -O subspace-cli https://github.com/subspace/subspace-cli/releases/download/v0.5.3-alpha-2/subspace-cli-ubuntu-x86_64-v2-v0.5.3-alpha-2
    sudo chmod +x subspace-cli
    sudo rm /usr/local/bin/subspace-cli
    sudo mv subspace-cli /usr/local/bin/

    source "$HOME/.bash_profile"
    sudo systemctl restart subspaced
}

update
printGreen "Your node has been updated successfully"
printGreen "Check your node status: journalctl -u subspaced -f -o cat"
