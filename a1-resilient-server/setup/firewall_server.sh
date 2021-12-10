#!/bin/sh

gateway_iface=$(ip a | grep 10.1.5.2 | tail -c 5)
detlab_iface=$(ip a | grep 192.168 | tail -c 5)

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Delete all
iptables -F
iptables -t nat -F
iptables -t mangle -F

# Delete all
iptables -X
iptables -t nat -X
iptables -t mangle -X

# Zero all packets and counters.
iptables -Z
iptables -t nat -Z
iptables -t mangle -Z

echo 50576 64768 98152 > /proc/sys/net/ipv4/tcp_mem

echo 4096 87380 16777216 > /proc/sys/net/ipv4/tcp_rmem

echo 4096 65536 16777216 > /proc/sys/net/ipv4/tcp_wmem

echo 16777216 > /proc/sys/net/core/rmem_max

echo 16777216 > /proc/sys/net/core/wmem_max

echo 4096 > /proc/sys/net/core/netdev_max_backlog

echo 2 > /proc/sys/net/ipv4/tcp_fin_timeout

echo 2 > /proc/sys/net/ipv4/tcp_synack_retries

echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control

#Enhance syn backlog
echo 4096 > /proc/sys/net/ipv4/tcp_max_syn_backlog

# Protect against SYN flood attacks
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

# Ignore all incoming ICMP echo requests
echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_all

# Ignore ICMP echo requests to broadcast
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# Don't log invalid responses to broadcast
echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses

## DNS functionalities UDP
iptables -A OUTPUT -m state --state NEW -p udp --dport 53 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -p udp --dport 53 -j ACCEPT

#Loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#All traffic from deterlab interfaces
iptables -A INPUT -i $detlab_iface -j ACCEPT
iptables -A OUTPUT -o $detlab_iface -j ACCEPT

#Allow input for server
#iptables -A INPUT -i $gateway_iface -p tcp --dport 80 -m connlimit --connlimit-above 5 -j DROP

iptables -A INPUT -i $gateway_iface -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -o $gateway_iface -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#Default deny
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP