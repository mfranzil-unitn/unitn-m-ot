#! bin/bash

sudo sqlmap -u "server/process.php?user=dima1234&pass=dima1234567&amount=1&drop=register" --batch --banner

