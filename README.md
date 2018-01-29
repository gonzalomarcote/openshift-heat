# openshif-heat
OpenShift Container Platform installation using OpenStack Heat Orchestration Service

Author: Gonzalo Marcote - gonzalomarcote_at_gmail.com

License: GNU General Public License V3.0

Disclaimer: For my own use. Modify it to your own usage (GNU GPL License).

### Script to configure one OpenShift Container Platform installation using OpenStack Heat Orchestration Service

#### Usage
Required packages: openstack client with Heat support

Just edit ocp3X-template.yml and fill with your own variables:

	image: -> your image name
	favor: -> your flavor
	key_name: -> your ssh key name

Run the stack with these commands:

`$ export INSTALL=quick`

`$ openstack stack create --wait -t ocp35-template.yml --parameter 'PARTITION=1' --parameter 'USER=rhn-support-gmarcote' --parameter 'PASS=1019goN\$4' --parameter 'POOLID=8a85f9813cf493fe013d028b6cf75b5a' --parameter 'VOL=docker-vg' --parameter 'HTUSER=gonzalo' --parameter 'HTPASS=1019goN\$4' --parameter 'HTADMINPASS=1019goN\$44'n ocp35-stack`

`$ openstack stack create -t ocp3X-template.yml --parameter "PARTITION=1" --parameter "USER=rhn-support-gmarcote" --parameter "PASS=1019goN\$4" --parameter "POOLID=8a85f9813cf493fe013d028b6cf75b5a" --parameter "VOL=docker-vg" --parameter "HTUSER=gonzalo" --parameter "HTPASS=1019goN\$4" --parameter "HTADMINPASS=1019goN\$44" --parameter "CONFIG=ocp35-1master-2nodes.cfg.yml" ocp3X-stack`

`$ openstack stack list`

`$ openstack server list`

`$ openstack stack output show --all ocp3X-stack`

`$ openstack stack delete --yes ocp3X-stack`
