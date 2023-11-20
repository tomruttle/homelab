#!/bin/bash

sudo apt-add-repository ppa:maas/3.4-next
sudo apt-get install -yq maas
sudo apt purge snapd -yq
sudo apt-get autoremove

sudo maas createadmin
