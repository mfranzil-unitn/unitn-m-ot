#! bin/bash

# common directory names
# wget wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt

#sec List repo
#https://github.com/danielmiessler/SecLists


echo "starting gobuster"
echo "guessing directories"
gobuster dir -u http://127.0.0.1:8888 -w common.txt --exclude-length 508

# exclude lenght 508 in order to escape the server return page for non existing urls

