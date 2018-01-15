#!/bin/bash
# This script create the docker-vg LVM volume group at boot needed for docker
# It is passed as user-data to the instance
fdisk /dev/vda <<EEOF
n
p
3


t
3
8e
w
EEOF
partx -u /dev/vda
pvcreate /dev/vda3
vgcreate docker-vg /dev/vda3
echo $INSTALL > /home/cloud-user/install.txt
exit 0
