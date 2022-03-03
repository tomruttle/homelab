#!/bin/bash

sudo apt-add-repository ppa:maas/3.1
sudo apt-get install -yq maas

sudo snap remove lxd && sudo snap remove core18 && sudo snap remove core20 && sudo snap remove snapd
sudo apt purge snapd -yq

sudo apt-get autoremove

sudo maas createadmin
