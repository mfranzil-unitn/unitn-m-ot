#!/bin/bash

sudo apt-get install nmap sqlmap ncrack
sudo apt install python3-pip -y
cd ~/cctf-ss/attack/tools/psw_brute_force/requests-futures/
sudo python3 setup.py install
