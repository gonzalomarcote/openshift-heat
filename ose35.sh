#!/bin/bash
#subscription-manager register --username=rhn-support-gmarcote --password=1019goN\$4
#subscription-manager attach --pool=8a85f9813cf493fe013d028b6cf75b5a
subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.5-rpms" --enable="rhel-7-fast-datapath-rpms"
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct vim
yum -y update
yum -y install atomic-openshift-utils
yum -y install atomic-openshift-excluder atomic-openshift-docker-excluder
atomic-openshift-excluder unexclude
yum -y install docker
cat <<EOF > /etc/sysconfig/docker-storage-setup
VG=docker-vg
EOF
docker-storage-setup
lvextend -l +100%FREE docker-vg/docker-pool
systemctl enable docker
systemctl start docker
