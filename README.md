# openshif-heat
OpenShift Container Platform installation using OpenStack Heat Orchestration Service

Author: Gonzalo Marcote - gonzalomarcote_at_gmail.com

License: GNU General Public License V3.0

Disclaimer: For my own use. Modify it to your own usage (GNU GPL License).

### Script to configure one OpenShift Container Platform installation using OpenStack Heat Orchestration Service

#### Usage
Required packages: openstack client with Heat support

Just edit openshift-template.yml and fill with your own variables:

	image: -> your image name
	favor: -> your flavor
	key_name: -> your ssh key name

Run the stack with these commands (specify AZ if you want to launch in a specific node):

`$ export NET_ID=$(openstack network list | awk '/ provider / { print $2 }')`

`$ openstack stack create -t openshift-template.yml --parameter "NetID=$NET_ID" openshift-stack`

`$ openstack stack list`

`$ openstack server list`

`$ openstack stack output show --all openshift-stack`

`$ openstack stack delete --yes openshift-stack`
