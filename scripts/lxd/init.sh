#!/bin/bash

# Add software repository
apt-get update -y
apt-get install -y python-software-properties software-properties-common
add-apt-repository ppa:ubuntu-cloud-archive/liberty-staging
add-apt-repository ppa:ubuntu-lxc/lxd-stable
# comment above ppa and uncomment below to get development lxd builds
#add-apt-repository ppa:ubuntu-lxc/lxd-git-master

# Update repositories
apt-get update -y

# Disable interactive options when installing with apt-get
export DEBIAN_FRONTEND=noninteractive

# Don't automatically install recommended or suggested packages
mkdir -p /etc/apt/apt.config.d
echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.config.d/99local
echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.config.d/99local

# Disable firewall (this is not production)
ufw disable

apt-get install -y lxd 

mkdir -p /vagrant/images

# create ubuntu-14.04.x-amd64 root-tar image
lxc-create -t ubuntu -n ubuntu-14.04.3-amd64
lxc-start -n ubuntu-14.04.3-amd64
lxc-stop -n ubuntu-14.04.3-amd64
cd /var/lib/lxc/ubuntu-14.04.3-amd64/rootfs/
rm -f /vagrant/images/ubuntu-14.04.3-amd64-root.tar.gz
tar -czf /vagrant/images/ubuntu-14.04.3-amd64-root.tar.gz .

# create centos-6.7-amd64 root-tar image
apt-get install -y yum
lxc-create -t centos -n centos-6.7-amd64
lxc-start -n centos-6.7-amd64
lxc-attach -n centos-6.7-amd64 <<EOF
yum install -y http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum install -y cloud-init
EOF
lxc-stop -n centos-6.7-amd64
cd /var/lib/lxc/centos-6.7-amd64/rootfs/
rm -f /vagrant/images/centos-6.7-amd64-root.tar.gz
tar -czf /vagrant/images/centos-6.7-amd64-root.tar.gz .

rm -f /vagrant/images/import-images.sh
cat >> /vagrant/images/import-images.sh <<EOF
glance image-create --name 'ubuntu-14.04.3-amd64' \
	--container-format bare \
	--disk-format raw \
	--visibility public \
	--min-disk 5 \
	--property architecture=x86_64 \
	--property hypervisor_type=lxc \
	--property os_distro=ubuntu \
	--property os_version=14.04.3 \
	--property vm_mode=exe < ubuntu-14.04.3-amd64-root.tar.gz

glance image-create --name 'centos-6.7-amd64' \
	--container-format bare \
	--disk-format raw \
	--visibility public \
	--min-disk 5 \
	--property architecture=x86_64 \
	--property hypervisor_type=lxc \
	--property os_distro=centos \
	--property os_version=6.7 \
	--property vm_mode=exe < centos-6.7-amd64-root.tar.gz
EOF

shutdown -P 1
exit 0