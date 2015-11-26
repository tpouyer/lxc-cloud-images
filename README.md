lxc-cloud-images
=============

This repository provides a vagrant setup to produce lxc style rootfs tar images.
It is intended that these images be used with the stackinabox project (DevStack Liberty w/ LXD)

### Getting Started
- copy the Personalization.dict file in the vagrant directory.
- edit the values of the properties you wish to change
- look in the scripts directory for setup scripts for the following:
   - virtualbox
   - vagrant
   - vagrant plugins:
      - vbguest
      - cachier
   - nfs shared filesystem
   - add box
- once you have your system setup run the following command from the vagrant directory:  
````vagrant up --provider=virtualbox````
