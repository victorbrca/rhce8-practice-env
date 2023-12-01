# Setting Up the Environment

Follow the instructions below to setup the lab environment on your machine. We will be installing the requirements, then cloning this repo and initializing the VMs.

## Compatibility 

I run Linux (Arch) on my machine and that's where I developed and tested the code for this lab. While I have not tested it with other OSs (e.g.: Windows, MacOS), it uses Vagrant and VirtualBox, so it should be fully compatible.

## Install the Required Software

+ Vagrant - [Vagrant Downloads](https://www.vagrantup.com/downloads.html)
+ Vagrant Ansible plugin - `vagrant plugin install vagrant-guest_ansible`
+ VirtualBox and Virtual Box Extension Pack - [Virtualbox Downloads](https://www.virtualbox.org/wiki/Downloads)
+ Git (optional)
+ Ansible (optional)

## Initialize and Start the Environment

Once the required software is installed, do the following:

a. Clone the environment repo to your machine - https://github.com/victorbrca/rhce8-practice-env

b. Change to the cloned repo folder

c. Run `vagrant up` to deploy the environment

>[!NOTE]
> + If it's the first time, it may take a while to download the boxes. Be patient.
> + A few error messages are normal during the provisioning of the environment.
