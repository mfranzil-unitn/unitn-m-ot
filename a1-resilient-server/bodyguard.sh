#!/bin/bash


name=$(hostname | sed "s/\..*$//")

if [[ $name == "server" ]]; then
    CHAIN="INPUT"
else
    CHAIN="PREROUTING"
fi

while true; do
    clear 
    figlet bodyguard
    date +'[%H:%M:%S] ======='
    echo "Choose what to do."
    echo "[1] 1 active, 2 banned, 3 banned"
    echo "[2] 1 banned, 2 active, 3 banned"
    echo "[3] 1 banned, 2 banned, 3 active"
    echo "[a] all active"
    echo "[e] exit"
    read -rp "> " option

    sudo iptables -D $CHAIN -s 10.1.2.2/24 -d 0/0 -j DROP
    sudo iptables -D $CHAIN -s 10.1.2.2/24 -d 0/0 -j ACCEPT
    sudo iptables -D $CHAIN -s 10.1.3.2/24 -d 0/0 -j DROP
    sudo iptables -D $CHAIN -s 10.1.3.2/24 -d 0/0 -j ACCEPT
    sudo iptables -D $CHAIN -s 10.1.4.2/24 -d 0/0 -j DROP
    sudo iptables -D $CHAIN -s 10.1.4.2/24 -d 0/0 -j ACCEPT

    if [[ $option == 1 ]]; then
        sudo iptables -I $CHAIN -s 10.1.2.2/24 -d 0/0 -j ACCEPT
        sudo iptables -I $CHAIN -s 10.1.3.2/24 -d 0/0 -j DROP
        sudo iptables -I $CHAIN -s 10.1.4.2/24 -d 0/0 -j DROP
        echo "1 is now active"
    elif [[ $option == 2 ]]; then
        sudo iptables -I $CHAIN -s 10.1.2.2/24 -d 0/0 -j DROP
        sudo iptables -I $CHAIN -s 10.1.3.2/24 -d 0/0 -j ACCEPT
        sudo iptables -I $CHAIN -s 10.1.4.2/24 -d 0/0 -j DROP
        echo "2 is now active"
    elif [[ $option == 3 ]]; then
        sudo iptables -I $CHAIN -s 10.1.2.2/24 -d 0/0 -j DROP
        sudo iptables -I $CHAIN -s 10.1.3.2/24 -d 0/0 -j DROP
        sudo iptables -I $CHAIN -s 10.1.4.2/24 -d 0/0 -j ACCEPT
        echo "3 is now active"
    elif [[ $option == a ]]; then
        sudo iptables -I $CHAIN -s 10.1.2.2/24 -d 0/0 -j ACCEPT
        sudo iptables -I $CHAIN -s 10.1.3.2/24 -d 0/0 -j ACCEPT
        sudo iptables -I $CHAIN -s 10.1.4.2/24 -d 0/0 -j ACCEPT
        echo "all are now active"
    elif [[ $option == 'e' ]]; then
        echo "Exit"
        exit
    else
        echo "Invalid option"
        exit
    fi
done