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
# Ensure ssh host access between master and hosts
sed -i 's/.*10" //g' /root/.ssh/authorized_keys
#subscription-manager register --username=$USER --password=$PASS
#subscription-manager attach --pool=$POOLID
subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.5-rpms" --enable="rhel-7-fast-datapath-rpms"
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
# Create OCP install file ocp35-cfg.yml
cat <<EEEOF | sudo tee /root/ocp35-cfg.yml
ansible_log_path: /tmp/ansible.log
deployment:
  ansible_ssh_user: root
  hosts:
  - connect_to: ocp35.marcote.org
    hostname: ocp35.marcote.org
    ip: 192.168.1.53
    public_hostname: ocp35.marcote.org
    public_ip: 192.168.1.53
    roles:
    - master
    - etcd
    - node
    - storage
  - connect_to: ocp35node1.marcote.org
    hostname: ocp35node1.marcote.org
    ip: 192.168.1.51
    node_labels: '{''region'': ''infra''}'
    public_hostname: ocp35node1.marcote.org
    public_ip: 192.168.1.51
    roles:
    - node
  - connect_to: ocp35node2.marcote.org
    hostname: ocp35node2.marcote.org
    ip: 192.168.1.52
    node_labels: '{''region'': ''infra''}'
    public_hostname: ocp35node2.marcote.org
    public_ip: 192.168.1.52
    roles:
    - node
  master_routingconfig_subdomain: ocp35apps.marcote.org
  openshift_master_cluster_hostname: None
  openshift_master_cluster_public_hostname: None
  proxy_exclude_hosts: ''
  proxy_http: ''
  proxy_https: ''
  roles:
    etcd: {}
    master: {}
    node: {}
    storage: {}
variant: openshift-enterprise
variant_version: '3.5'
version: v2
EEEOF
# Copy ssh key file
cat <<EEEEOF | sudo tee /root/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAu+i1UERevujzFJz0iajsYSxG2t7+kSgFtnQ45S5k5XgLSgF7
8cXnjtGIQ2UQkDbU/1mJMM0thyd/T0NVBvQA93rrLgbvwV2Cw7qm7/JFE1AhFhDg
0M7cNGKUja3IwYIrZF+UheAGR8Zg6E+xEp91B4m+6EdhkjTM6mXMTb+8thaGnbHb
/5UV9eI/9JIJiTuZ9AObSOiXrPoDopK+riNPIIajMwmXj3n3LCCMnLENQL83Z1vY
kApBo3nbhO99DU5kPJRTrPZLK9Ew5lrkof1S65pxnzt57tIiQS37YbQAXIOICRdO
UmVscXf/NmTpIoBaXeA6X8lPqsISn30vRkCgIQIDAQABAoIBAQCM+bmNzr2GXR6B
iH+uB53QCXffHQ2/uVcP24IT7wqjXbyaeSKT8PYYn/qrFVen2ntSV8olYsmVbHyG
6u0PmmBfS0jF705Qs+c3EQHNYuWP573q4B7KiWeLpant4UOMaixD0bGL/ta3Yo2x
vJgMcLVMQnuHqIX7OsHB2T291uutb09DUK97Zj7SN8GeTWeRyDqodW2m985DNoXv
B7OiE6VBAzKUOzjycCDDl+S0Pm6oE2XE2cEULHKwgVgLeRc/q5xvJ4Nr6LZMfld9
QFjFGDg4uhYvTAR5vuM0Fz65SkF2BdLH1mGpKzbztt/BIbuyDaZeisIqLj41jckO
aYUqN2wBAoGBAOipKIwDKYCLIa6d/nM0vVuPhGzFudTrM8YFwKx3S5H44L587e2q
rdgbLQAE4E3K8Ju4FgjuyAjZJOb7WGnj+xpzFpQj8/flOfDobQt6iL2V9xtlNTa0
wKfRLSN6xaxNO8TnjkxA/eAD903luWByGeFtVex7NGwTY38YDEc8zO+ZAoGBAM7C
TZE8M/cXVBVDgSVe/aMwg2YDXM1HigvEPJseZWeTPFNi+tsOfIwYPLtuZVngQv+G
nyrxvs/sd2ZEW1SC3VjPOAHplMQg6YkoX9z1N3NXNXYq2eyO8JaUWoysfI80pZo9
ZSMPQTogdK2w9tv5vpEI8W8F5ubnXUAoyrEeYSnJAoGAI1oApTWdysBZP9UV4p9y
3kSyVGy+zdFnLoGVQx9lRirQy2DkLiau/5Uxgz06b9eUM7UG9BiEIIQODWLHjl9r
uhsepSfJXDNiWG6YkxPtTxFIWMtKCKPyWg14lFmFS6b4m/SrNH7zlGRF4Xo0bqkn
sY8RbTtTPdC8X4Vh6Dke0pECgYEAy+ttT2neIrx6bIJolHAsnk/RuMJmO/xr1ZEU
6TTAdLgNjnyXx4dxJUceVwnZohwCWDzxLQzC0hV56X5PyXlMUDQIHDLBS/LeAi20
5ptftj1z9/jpeFu+Q/VLnWTdcOxOzGHzJvH7thWenlRkFK8r2aXFYWejxWa5XPce
ejPpRqkCgYEA10GAQuUVU4EwnOuoDfiFUs0fbsFlbxjGQX+t+ABYCDiCj4rUX/ge
tybdpGCQOCrse1rRYKlHEz9KsPP6jx1eE4VsSsFPR+pTxnyWnBPRY+uBSwVeHzMd
5lJzfyLPyJI/bulwh/v8yaYcEfggFrhMyLfKfy1O2e1iyAmt1MbiYyM=
-----END RSA PRIVATE KEY-----
EEEEOF
# Set id_rsa permissions
chmod 600 /root/.ssh/id_rsa
# Unattended install of OCP 3.5
atomic-openshift-installer -u -c /root/ocp35-cfg.yml install
# Verify installation
#oc get nodes -o wide -L region
#oc get pods -o wide
# Configure OpenShift for Apache HTPasswd authentication and create the initial users
sed -i.bak "s/DenyAllPasswordIdentityProvider/HTPasswdPasswordIdentityProvider\\n      file: \/etc\/origin\/openshift-passwd/g" /etc/origin/master/master-config.yaml
touch /etc/origin/openshift-passwd
systemctl restart atomic-openshift-master
htpasswd -b /etc/origin/openshift-passwd $HTUSER "$HTPASS"
htpasswd -b /etc/origin/openshift-passwd admin "$HTADMINPASS"
oc adm policy add-cluster-role-to-user cluster-admin admin
