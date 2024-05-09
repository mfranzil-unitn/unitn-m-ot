#!/bin/bash
ETH=...

SYNCOOKIES=$(sudo sysctl net.ipv4.tcp_syncookies | awk '{print $3}')
if [[ $SYNCOOKIES -eq 1 ]]; then
    sudo sysctl -w net.ipv4.tcp_syncookies=0
    sudo sysctl -w net.ipv4.tcp_max_syn_backlog=10000
fi
SYNCOOKIES=$(sudo sysctl net.ipv4.tcp_syncookies | awk '{print $3}')
if [[ $SYNCOOKIES -eq 0 ]]; then echo "OK"; else echo "KO"; fi

/share/education/TCPSYNFlood_USC_ISI/install-server

sudo tcpdump ip -i ${ETH}