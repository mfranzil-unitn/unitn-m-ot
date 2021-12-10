#!/bin/bash

router_iface=$(ip a | grep 10.1.1.3 | tail -c 5)

iptables -t mangle -I PREROUTING -i $router_iface -p tcp -m conntrack --ctstate NEW ! --tcp-option 4 -j DROP

iptables -t mangle -I PREROUTING -i $router_iface -p tcp -m conntrack --ctstate NEW ! --tcp-option 1 -j DROP


#iptables -t mangle -I PREROUTING -p tcp -m connlimit --connlimit-above 5 -j DROP

