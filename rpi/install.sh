#!/bin/bash

PROFILE=tom
EMAIL_ADDRESS=tom@tomruttle.com
SSH_IMPORT=gh:tomruttle

sudo apt-get install -yq nfs-kernel-server

echo "/opt/data *(rw,sync,no_root_squash,no_wdelay,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -a
sudo systemctl start nfs-kernel-server.service

sudo apt-add-repository ppa:maas/3.1
sudo apt-get install -yq maas

sudo apt-get autoremove

# sudo maas createadmin --username=$PROFILE --email=$EMAIL_ADDRESS --ssh-import=$SSH_IMPORT --password=$PASSWORD
