#!/bin/sh

router_iface=$(ip a | grep 10.1.1.3 | tail -c 5)
server_iface=$(ip a | grep 10.1.5.3 | tail -c 5)
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

# Don't accept or send ICMP redirects.
for i in /proc/sys/net/ipv4/conf/*/accept_redirects; do echo 0 > "$i"; done
for i in /proc/sys/net/ipv4/conf/*/send_redirects; do echo 0 > "$i"; done

# Don't accept source routed packets.
for i in /proc/sys/net/ipv4/conf/*/accept_source_route; do echo 0 > "$i"; done

# Disable multicast routing
#for i in /proc/sys/net/ipv4/conf/*/mc_forwarding; do echo 0 > "$i"; done

# Disable proxy_arp.
#for i in /proc/sys/net/ipv4/conf/*/proxy_arp; do echo 0 > "$i"; done

### Drop invalid packets ### 
iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

### Drop TCP packets that are new and are not SYN ### 
iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
 
### Drop SYN packets with suspicious MSS value ### 
iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 1400:1500 -j DROP

#iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW ! --tcp-option 4 -j DROP

### Block packets with bogus TCP flags ### 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP  
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j DROP  


### Drop ICMP (you usually don't need this protocol) ### 
iptables -t mangle -A PREROUTING -p icmp -j DROP

### Drop fragments in all chains ### 
iptables -t mangle -A PREROUTING -f -j DROP  

### Limit connections per source IP ### 
#iptables -A FORWARD -p tcp -m connlimit --connlimit-above 5 -j DROP
#iptables -A INPUT -p tcp -m connlimit --connlimit-above 5 -j DROP
#Add to mitigate slow loris


## DNS functionalities UDP
iptables -A OUTPUT -m state --state NEW -p udp --dport 53 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -p udp --dport 53 -j ACCEPT

### 9: Limit RST packets ### 
iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT

#Loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#All traffic from deterlab interfaces
iptables -A INPUT -i $detlab_iface -j ACCEPT
iptables -A OUTPUT -o $detlab_iface -j ACCEPT

#Allow forwarding
iptables -A FORWARD -i $router_iface -o $server_iface -s 10.1.1.2,10.1.3.2,10.1.4.2,10.1.2.2 -d 10.1.5.2 -p tcp --dport 80 -m conntrack --ctstate NEW -m limit --limit 10000/s --limit-burst 30 -j ACCEPT
iptables -A FORWARD -i $router_iface -o $server_iface -p tcp --dport 80 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $server_iface -o $router_iface -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#Allow sending requests and receiving answers from the server
iptables -A OUTPUT -o $server_iface -d 10.1.5.2 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -i $server_iface -s 10.1.5.2 -p tcp -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP