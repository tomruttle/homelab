#!/bin/bash

sudo apt-add-repository ppa:maas/3.4-next
sudo apt-get install -yq maas

sudo snap remove lxd core18 core20 core22 bare snapd
sudo apt purge snapd -yq

sudo apt-get autoremove

sudo maas createadmin
