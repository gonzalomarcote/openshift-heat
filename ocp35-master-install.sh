#!/bin/bash
# This script file is passed as user-data to the instance
echo $PARTITION > /root/vars-master-install.txt
echo $USER >> /root/vars-master-install.txt
echo $PASS >> /root/vars-master-install.txt
echo $POOLID >> /root/vars-master-install.txt
echo $VOL >> /root/vars-master-install.txt
echo $HTUSER >> /root/vars-master-install.txt
echo $HTPASS >> /root/vars-master-install.txt
echo $HTADMINPASS >> /root/vars-master-install.txt
# Create the docker-vg LVM volume group at boot needed for docker if PARTITION = 1
if [ "$PARTITION" -eq 1 ]
then
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
else
echo "Disk already partitioned with an extra LVM Volume Gorup calleed docker-vg"
fi
subscription-manager register --username=$USER --password=$PASS
subscription-manager attach --pool=$POOLID
subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.5-rpms" --enable="rhel-7-fast-datapath-rpms"
yum -y update
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct vim httpd-tools
yum -y install atomic-openshift-utils
yum -y install atomic-openshift-excluder atomic-openshift-docker-excluder
atomic-openshift-excluder unexclude
yum -y install docker
cat <<EOF | sudo tee -a /etc/sysconfig/docker-storage-setup
VG=$VOL
EOF
docker-storage-setup
lvextend -l +100%FREE $VOL/docker-pool
systemctl enable docker
systemctl start docker
# Ensure ssh host access between master and hosts (done manually)
# Copy installer.cfg.yml config file (done manually)
atomic-openshift-installer -u -c $CONFIG install
# Verify installation
oc get nodes -o wide -L region
oc get pods -o wide
# Configure OpenShift for Apache HTPasswd authentication and create the initial users
sed -i.bak "s/DenyAllPasswordIdentityProvider/HTPasswdPasswordIdentityProvider\\n      file: \/etc\/origin\/openshift-passwd/g" /etc/origin/master/master-config.yaml
touch /etc/origin/openshift-passwd
systemctl restart atomic-openshift-master
htpasswd -b /etc/origin/openshift-passwd $HTUSER $HTPASS
htpasswd -b /etc/origin/openshift-passwd admin $HTADMINPASS
#oc adm policy add-cluster-role-to-user cluster-admin admin
