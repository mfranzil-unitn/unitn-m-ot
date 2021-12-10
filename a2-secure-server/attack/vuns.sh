# Negative amount
server/process.php/user=dima&pass=dima&amount=-500&drop=register

#muliple amount
server/process.php/user=dima&pass=dima&amount=[500,300]&drop=register

#special charatters attack --> chinese charatters
localhost:8888/process.php?user='c十二十二十二aaaaaaaaa&pass='caaaaaaaaaaaa&amount=1&drop=register

#try to download proccess file
wget server/proccess.php

#scan with gobuster for files and folders
https://null-byte.wonderhowto.com/how-to/scan-websites-for-interesting-directories-files-with-gobuster-0197226/ # guide
https://github.com/danielmiessler/SecLists.git # sec list
https://github.com/OJ/gobuster # gobuster repo




