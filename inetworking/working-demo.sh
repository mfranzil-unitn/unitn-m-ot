# This command takes a long time so we'll execute it once
/share/shared/Internetworking/showcabling Franzil-Iworking offtech | sed 's/ <- is "wired" to -> /;/' > eths.txt

cat eths.txt | grep NWworkstation1 | sed 's/workstation1 /W_SOUTH=/' | sed 's/router /R_NORTH=/' >> ports.sh
cat eths.txt | grep NWrouter | grep ISrouter | sed 's/ISrouter /IS_NORTH=/' | sed 's/NWrouter /NWR_SOUTH=/' >> ports.sh
cat eths.txt | grep SWrouter | grep ISrouter | sed 's/ISrouter /IS_SOUTH=/' | sed 's/SWrouter /SWR_NORTH=/' >> ports.sh
cat eths.txt | grep SWworkstation1 | sed 's/workstation1 /W_NORTH=/' | sed 's/router /R_SOUTH=/' >> ports.sh

# Include the ports in our script
. ports.sh

###### NW-W

cat <<EOF > nww.sh
ip a add 10.0.100.1/28 dev $NWW_SOUTH
ip link set $NWW_SOUTH up

ip r add 2.0.100.0/28 dev $NWW_SOUTH via 10.0.100.2
ip r add 3.0.100.0/28 dev $NWW_SOUTH via 10.0.100.2
ip r add 10.4.100.0/28 dev $NWW_SOUTH via 10.0.100.2
EOF

chmod +x nww.sh

ssh NWworkstation1.franzil-iworking.offtech "sudo su -c ./nww.sh"

###### NW-R

cat <<EOF > nwr.sh
ip a add 10.0.100.2/28 dev $NWR_NORTH
ip a add 2.0.100.1/28 dev $NWR_SOUTH
ip link set $NWR_NORTH up
ip link set $NWR_SOUTH up

ip r add 3.0.100.0/28 dev $NWR_SOUTH via 2.0.100.2
ip r add 10.4.100.0/28 dev $NWR_SOUTH via 2.0.100.2

# NAT

iptables -t nat -A POSTROUTING -o $NWR_SOUTH -s 10.0.100.0/28 -j SNAT --to 2.0.100.1
EOF
chmod +x nwr.sh

ssh nwrouter.franzil-iworking.offtech "sudo su -c ./nwr.sh"

###### IS

cat <<EOF > isr.sh
ip a add 2.0.100.2/28 dev $IS_NORTH
ip a add 3.0.100.1/28 dev $IS_SOUTH
ip link set $IS_NORTH up
ip link set $IS_SOUTH up

ip r add 10.0.100.0/28 dev $IS_NORTH via 2.0.100.1
ip r add 10.4.100.0/28 dev $IS_SOUTH via 3.0.100.2

iptables -I FORWARD -d 192.168.0.0/16 -j DROP
iptables -I FORWARD -d 172.16.0.0/12 -j DROP
iptables -I FORWARD -d 10.0.0.0/8 -j DROP
iptables -I FORWARD -s 192.168.0.0/16 -j DROP
iptables -I FORWARD -s 172.16.0.0/12 -j DROP
iptables -I FORWARD -s 10.0.0.0/8 -j DROP
EOF

chmod +x isr.sh

ssh isrouter.franzil-iworking.offtech "sudo su -c ./isr.sh"

###### SW-R

cat <<EOF > swr.sh
ip a add 3.0.100.2/28 dev $SWR_NORTH
ip a add 10.4.100.1/28 dev $SWR_SOUTH
ip link set $SWR_SOUTH up
ip link set $SWR_NORTH up

ip r add 10.0.100.0/28 dev $SWR_NORTH via 3.0.100.1
ip r add 2.0.100.0/28 dev $SWR_NORTH via 3.0.100.1

# NAT
iptables -t nat -A POSTROUTING -o $SWR_NORTH -s 10.4.100.0/28 -j SNAT --to 3.0.100.2

# Port forwarding
iptables -t nat -A PREROUTING -i $SWR_NORTH -d 3.0.100.2/32 -p tcp --dport 80 -j DNAT --to 10.4.100.2
EOF

chmod +x swr.sh

ssh swrouter.franzil-iworking.offtech "sudo su -c ./swr.sh"

###### SW-W

cat <<EOF > sww.sh
ip a add 10.4.100.2/28 dev $SWW_NORTH
ip link set $SWW_NORTH up

ip r add 10.0.100.0/28 dev $SWW_NORTH via 10.4.100.1
ip r add 2.0.100.0/28 dev $SWW_NORTH via 10.4.100.1
ip r add 3.0.100.0/28 dev $SWW_NORTH via 10.4.100.1
EOF

chmod +x sww.sh

ssh SWworkstation1.franzil-iworking.offtech "sudo su -c ./sww.sh"
