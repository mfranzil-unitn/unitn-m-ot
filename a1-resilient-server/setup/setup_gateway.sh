#!/bin/bash

sudo apt-get remove -y --purge man-db

echo "!!Installing pip3 and lxml!!"
sleep 1
sudo apt install python3-pip python3-lxml -y
echo "!!Installing pyshark dependencies!!"
sleep 1
pip3 install --no-index --find-links $HOME/cctf-g3/logger/dep/ -r $HOME/cctf-g3/logger/pyshark/requirements.txt 
echo "!!Installing pyshark!!"
sleep 1
cd $HOME/cctf-g3/logger/pyshark/src/

sudo python3 setup.py install

sudo bash "$HOME/cctf-g3/setup/firewall_gateway.sh"

echo "DONE"