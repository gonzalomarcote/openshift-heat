#!/bin/bash
# This script file is passed as user-data to the instance
echo $PARTITION > /root/vars-node-install.txt
echo $USER >> /root/vars-node-install.txt
echo $PASS >> /root/vars-node-install.txt
echo $POOLID >> /root/vars-node-install.txt
echo $VOL >> /root/vars-node-install.txt
# Create the docker-vg LVM volume group at boot needed for docker if PARTITION = 1
if [ "$PARTITION" -eq 1 ]
then
fdisk /dev/vda <<EOF
n
p
3


t
3
8e
w
EOF
partx -u /dev/vda
pvcreate /dev/vda3
vgcreate docker-vg /dev/vda3
else
echo "Disk already partitioned with an extra LVM Volume Gorup calleed docker-vg"
fi
# Ensure ssh host access between master and hosts (done manually)
sed -i 's/.*10" //g' /root/.ssh/authorized_keys
#subscription-manager register --username=$USER --password=$PASS
#subscription-manager attach --pool=$POOLID
subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-updates-rpms" --enable="rhel-7-server-ose-3.5-rpms" --enable="rhel-7-fast-datapath-rpms"
yum -y update
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct vim httpd-tools
yum -y install atomic-openshift-utils
yum -y install atomic-openshift-excluder atomic-openshift-docker-excluder
atomic-openshift-excluder unexclude
yum -y install docker
cat <<EEOF | sudo tee -a /etc/sysconfig/docker-storage-setup
VG=$VOL
EEOF
docker-storage-setup
lvextend -l +100%FREE $VOL/docker-pool
systemctl enable docker
systemctl start docker
