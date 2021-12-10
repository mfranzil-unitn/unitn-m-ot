#! bin/bash

echo "start nmap scanning: "
mkdir nmap
sudo nmap -sC -sV -oA nmap/server 10.1.5.2