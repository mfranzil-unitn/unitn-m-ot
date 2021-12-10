#!/bin/bash

# man-db takes ages and we don't need it on the server
sudo apt-get remove -y --purge man-db
sudo apt-get update

echo "!!Installing pip3 and lxml!!"
sleep 1
sudo apt-get install python3-pip python3-lxml -y

echo "!!Installing pyshark dependencies!!"
sleep 1
pip3 install --no-index --find-links $HOME/cctf-g3/logger/dep/ -r $HOME/cctf-g3/logger/pyshark/requirements.txt 

echo "!!Installing pyshark!!"
sleep 1

cd $HOME/cctf-g3/logger/pyshark/src/
sudo python3 setup.py install
cd -

echo "!!Configuring varnish rev-proxy!!"
sleep 1

sudo apt --fix-broken install $HOME/cctf-g3/setup/varnish_7.0.0-1~bionic_amd64.deb -y

sudo dd if=/dev/urandom of=/etc/varnish/secret count=1

sudo service varnish stop

echo "!!Configuring apache!!"
sleep 1
sudo apt-get install apache2 -y

sudo service apache2 stop

sudo cat <<EOF > /etc/apache2/ports.conf
Listen 8080

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>
EOF

sudo cat <<EOF > /etc/apache2/sites-enabled/000-default.conf
<VirtualHost *:8080>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOF

sudo echo "ServerTokens Prod" >> /etc/apache2/apache2.conf
sudo echo "ServerSignature Off" >> /etc/apache2/apache2.conf


#ssudo cat <<EOF > /etc/default/varnish
#START=yes
#NFILES=131072
#MEMLOCK=82000

#DAEMON_OPTS="-a :80 -T localhost:6082 -f /etc/varnish/cctf.vcl -S /etc/varnish/secret -s malloc,512m"
#EOF

sudo cat <<EOF > /lib/systemd/system/varnish.service
[Unit]
Description=Varnish Cache, a high-performance HTTP accelerator
After=network-online.target nss-lookup.target

[Service]
Type=forking
KillMode=process

# Maximum number of open files (for ulimit -n)
LimitNOFILE=131072

# Locked shared memory - should suffice to lock the shared memory log
# (varnishd -l argument)
# Default log size is 80MB vsl + 1M vsm + header -> 82MB
# unit is bytes
LimitMEMLOCK=85983232

# Enable this to avoid "fork failed" on reload.
TasksMax=infinity

# Maximum size of the corefile.
LimitCORE=infinity

ExecStart=/usr/sbin/varnishd \
	  -a :80 \
	  -a localhost:8443,PROXY \
	  -p feature=+http2 \
	  -f /etc/varnish/cctf.vcl \
	  -s malloc,1024m
ExecReload=/usr/sbin/varnishreload

[Install]
WantedBy=multi-user.target
EOF

sudo cat <<EOF > /etc/varnish/cctf.vcl
vcl 4.1;

backend default {
    .host = "127.0.0.1";
    .port = "8080";
}

sub vcl_recv {
    if(req.method != "GET"){
        return (synth(803, "Forbidden"));
    }
}

sub vcl_synth {
    if (resp.status == 803) {
        set resp.status = 403;
        return (deliver);
    }
}

sub vcl_backend_response {
    set beresp.ttl = 4w;
}

sub vcl_deliver {
    unset resp.http.Via;
    unset resp.http.X-Varnish;
    unset resp.http.Age;
    unset resp.http.Server;
}
EOF

sudo mkdir -p /var/www/html/

for i in {1..10}
do 
  sudo touch /var/www/html/$i.html
  echo $i.html
done

sudo rm /var/www/html/index.html
sudo touch /var/www/html/index.html

sudo systemctl daemon-reload

sudo service apache2 start

sudo service varnish start

sudo bash "$HOME/cctf-g3/setup/firewall_server.sh"

echo "DONE"