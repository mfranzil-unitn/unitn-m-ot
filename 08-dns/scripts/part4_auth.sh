#!/bin/bash
cd /etc/bind

sudo dnssec-keygen -r /dev/urandom -a RSASHA256 -b 2048 -n ZONE google.com
# Generated file: Kgoogle.com.+008+24630
sudo dnssec-keygen -r /dev/urandom -f KSK -a RSASHA256 -b 2048 -n ZONE google.com
# Generated file: Kgoogle.com.+008+25105

cp "*.key" ~

vi google.com
# Add these (and remember to update the version):
# ; Keys to be published in DNSKEY RRset
# $INCLUDE "/etc/bind/Kgoogle.com.+008+24630.key"
# $INCLUDE "/etc/bind/Kgoogle.com.+008+25105.key"

sudo dnssec-signzone -x -o google.com google.coM

vi named.conf.local
# change "/etc/bind/google.com" to "/etc/bind/google.com.signed" 

vi named.conf.options
# Add:
# dnssec-enable yes;
# dnssec-validation yes;
# dnssec-lookaside auto;

sudo rndc reconfig 

dig +dnssec www.google.com A
