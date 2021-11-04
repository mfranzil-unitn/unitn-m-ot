#!/bin/sh

cp "*.key" /etc/bind
cd /etc/bind

dig . dnskey | grep "257 "
dig google.com dnskey

# Create managed-keys: it should look like this
# managed-keys {
# google.com. initial-key 257 3 8 "AwEAAaiXr5bRdlfVOG09N5/aXstSLv4hUh3HNLKFvO/ ...
#                                 lGyD8iOQ5Rhqocvda8XGoIv3G0ImdBL9Y6H8Q56U="; 
# google.com. initial-key 256 3 8 "AwEAAbbZG2s63exlvFCXE//mhDV+kmt1C5lllCpLrzN ...
#                                 2uMUxyDmLahk6F6sXydD1IjhXHf++Xv4LdCI/gPc=";
# . initial-key 257 3 8 "AwEAAaz/tAm8yTn4Mfeh5eyI96WSVexTBAvkMgJzkKTOiW1vkIbzx ...
#                        4/ilBmSVIzuDWfdRUfhHdY6+cn8HFRm+2hM8AnXGXws9555KrUB5q
# };

echo "include \"/etc/bind/managed-keys\";" | sudo tee -a /etc/bind/named.conf

sudo rndc reconfig