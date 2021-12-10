#!/bin/sh

iptables -A PREROUTING -t nat -p tcp -s 10.1.1.2,10.1.3.2,10.1.4.2,10.1.2.2 -d 10.1.5.2 --dport 80 -m conntrack --ctstate NEW -m limit --limit 10000/s --limit-burst 30 -j DNAT --to-destination 127.0.0.1:80

iptables -A POSTROUTING -t nat -p tcp -s 127.0.0.1 --sport 80 -d 10.1.1.2,10.1.3.2,10.1.4.2,10.1.2.2 -j SNAT --to-source 10.1.5.2:80