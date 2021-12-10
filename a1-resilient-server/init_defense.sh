#!/usr/local/bin/bash

#Change in class
EXP_NAME="cctf-res3"

cd $HOME/cctf-g3 || (echo "cctf-g3 folder not found, please clone first" && exit)

git fetch origin main
git reset --hard FETCH_HEAD
git clean -df

echo ">> Configuring the server and gateway..."
sleep 1
ssh gateway.$EXP_NAME.offtech "sudo bash $HOME/cctf-g3/setup/setup_gateway.sh" & ssh server.$EXP_NAME.offtech "sudo bash $HOME/cctf-g3/setup/setup_server.sh"

exit 1