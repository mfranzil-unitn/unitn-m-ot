#!/bin/bash
ETH=...

cat <<EOF > script.sh
#!/bin/bash
while sleep 1; do curl server/index.html >/dev/null 2>/dev/null; done;
EOF

# sudo tcpdump -nn -i eth1

chmod +x script.sh
sudo tcpdump -nn -v -s0 -i ${ETH} -w cookie.pcap &
./script.sh
