#!/bin/bash

cd /usr/local/snort-2.9.2.2/src/dynamic-examples/dynamic-preprocessor || exit
sudo mv spp_example.c spp_example.c.bak

# Now edit the new spp
sudo vim spp_example.c

sudo cp -r /usr/local/snort-2.9.2.2/src/dynamic-preprocessors/include/ ..
sudo make
sudo make install