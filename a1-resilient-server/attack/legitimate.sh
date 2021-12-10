#!/bin/bash

if [ "$#" -ne 3 ];then
    echo "Usage: ./legitimate.sh <target> <minsleep> <maxsleep> - interval is [min, max[";
    exit 0
fi

rm times.log reqs.log

trap exit SIGINT

CTR=0

FLOOR=$2
CEIL=$(($3 - $2))
__sleep=0

while true; do
    clear
    cowsay legitimate | cowthink -n -s | lolcat 
    TM=$(date +'%H:%M:%S')
    echo "========== TIMES ==============" | lolcat 
    tail times.log -n 10
    echo "========== REQS ===============" | lolcat
    tail reqs.log -n 10
    echo "===============================" | lolcat
    sleep $__sleep # sleep 1-9 sec
    PAGE=$((1 + RANDOM % 10)) # contact 1-10
    curl -s -w "[$CTR@$TM] T: %{time_total}\tR: %{http_code}"\\n -o /dev/null "$1/$PAGE.html" >> times.log &
    __sleep=$((FLOOR + RANDOM % CEIL))
    echo "[$CTR@$TM] Contacted $PAGE, next in $__sleep" >> reqs.log
    CTR=$((CTR + 1))
done