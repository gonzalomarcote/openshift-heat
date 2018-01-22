#!/bin/bash
#subscription-manager register --username= --password=
#subscription-manager attach --pool=
sudo subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.5-rpms" --enable="rhel-7-fast-datapath-rpms"
sudo yum -y update
sudo yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct vim httpd-tools
sudo yum -y install atomic-openshift-utils
sudo yum -y install atomic-openshift-excluder atomic-openshift-docker-excluder
sudo atomic-openshift-excluder unexclude
sudo yum -y install docker
cat <<EOF | sudo tee -a /etc/sysconfig/docker-storage-setup
VG=docker-vg
EOF
sudo docker-storage-setup
sudo lvextend -l +100%FREE docker-vg/docker-pool
sudo systemctl enable docker
sudo systemctl start docker
# Ensure ssh host access
# Copy installer.cfg.yml config file
sudo atomic-openshift-installer -u -c ocp35-1master-2nodes.cfg.yml install
# Verify installation
sudo oc get nodes -o wide -L region
sudo oc get pods -o wide
# Configure OpenShift for Apache HTPasswd authentication and create the initial users
sed -i.bak "s/DenyAllPasswordIdentityProvider/HTPasswdPasswordIdentityProvider\\n      file: \/etc\/origin\/openshift-passwd/g" /etc/origin/master/master-config.yaml
touch /etc/origin/openshift-passwd
systemctl restart atomic-openshift-master
htpasswd -b /etc/origin/openshift-passwd gonzalo '1019goN$4'
htpasswd -b /etc/origin/openshift-passwd admin '1019goN$44'
oc adm policy add-cluster-role-to-user cluster-admin admin

