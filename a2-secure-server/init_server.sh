#!/bin/bash

CPATH="$HOME/cctf-ss/defense/"

printf "Removing man-db for performances\n"

sudo apt remove man-db --purge -y &>/dev/null

printf "Installing LEMP stack\n"

sudo apt update &>/dev/null
sudo apt install php-fpm php-mysql python3-mysql.connector python3-pip -y &>/dev/null
yes | sudo dpkg -i "$HOME"/cctf-ss/nginx_1.20.2.deb

sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password QH^T%U@gy4e3kd9*d^k6ixkzQ'
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password QH^T%U@gy4e3kd9*d^k6ixkzQ'

sudo apt install mysql-server -y &>/dev/null

printf "Copying configuration files\n"

#FPM is called from nginx
sudo cp "$CPATH"/config/php.ini /etc/php/7.2/fpm
sudo cp "$CPATH"/config/www.conf /etc/php/7.2/fpm/pool.d

sudo service php7.2-fpm restart

sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/sites-enabled

# NGINX
#sudo cp "$CPATH"/secure_server /etc/nginx/sites-available/

sudo cp "$CPATH"/config/nginx.conf /etc/nginx/
sudo cp "$CPATH"/config/secure_server /etc/nginx/sites-available

sudo ln -s /etc/nginx/sites-available/secure_server /etc/nginx/sites-enabled/
#sudo unlink /etc/nginx/sites-enabled/default
sudo service nginx restart

sudo mkdir -p /var/www/html
#sudo rm /var/www/html/*
sudo cp "$CPATH"/php/process.php /var/www/html
sudo cp "$CPATH"/php/index.php /var/www/html


# MYSQL config file
sudo cp "$CPATH"/config/mysqld.cnf /etc/mysql/mysql.conf.d

sudo service mysql restart
# MYSQL
printf "Building database \n"
sudo mysql -u"root" -p"QH^T%U@gy4e3kd9*d^k6ixkzQ" < "$CPATH"/sql/setup.sql

#sudo rm /var/tmp/x.log

# DB setup script
printf "Populating database \n"
php -f "$CPATH/php/setupdb.php"

sudo chown root:root /var/tmp/x.log
sudo chmod 400 /var/tmp/x.log

