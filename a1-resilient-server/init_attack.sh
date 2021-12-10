#!/usr/local/bin/bash

EXP_NAME="cctf-res3"

git fetch origin main
git reset --hard FETCH_HEAD
git clean -df

echo ">> Configuring the attack machines"
TARGETS=(client1 client2 client3)

for MACHINE in "${TARGETS[@]}"
do
    ssh "$MACHINE.$EXP_NAME.offtech" "sudo bash \$HOME/cctf-g3/setup/setup_attack.sh" >> "init_attack_$MACHINE.log" &
done

#ssh server.cctf-g3.offtech "sudo apt-get update && sudo apt install apache2 -y && for i in {1..10}; do sudo touch /var/www/html/$i.html; echo $i.html | sudo tee $i.html; done;"
