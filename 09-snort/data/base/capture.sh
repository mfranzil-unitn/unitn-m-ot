#!/bin/bash

echo "" > snort.config
sudo snort --daq nfq -Q -c snort.config -l alerts > /dev/null 2>&1 &
RUNNING_PID=$!
sudo timeout 60s tcpdump -s 0 -w guard_no_rule.pcap
sudo kill ${RUNNING_PID}

read -rp "Press [Enter] key to continue..."

echo 'reject tcp 100.1.200.10 ANY -> 100.1.10.10 7777 (msg: "Data Exfiltration"; sid:1; content:"classified";)' > snort.config
sudo snort --daq nfq -Q -c snort.config -l alerts > /dev/null 2>&1 &
RUNNING_PID=$!
sudo timeout 60s tcpdump -s 0 -w guard_rule.pcap
sudo kill ${RUNNING_PID}