#!/bin/bash
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
#lvcreate -n docker-pool -l 100%FREE docker-vg
exit 0
