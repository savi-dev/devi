DEVI
====
Devi is a documented shell script to build complete SAVI testbed development environments.

## Copyright
Copyright (C) 2012, The SAVI Project. http://www.savinetwork.ca

Goals
-----

* To quickly build dev SAVI environments in a clean Ubuntu or Fedora environments
* To describe working configurations of SAVI
* To install all required software (MySQL, JDK7, Python27, Apache Ant and Ivy)
* To install yak
* To download all projects from SAVI repository based on configuration
* To build all projects
* To drop a database 'aoncontroldb' and restore a database dump
* To run using screen
* To test using examples

IMPORTANT: Be sure to carefully read 'savi.sh' and any other scripts you execute before you run them, as they install software and may alter your networking configuration. We strongly recommend that you run 'savi.sh' in a clean and disposable vm when you are first getting started. Please, see the installation guide in this file.

Installation
------------

### Install VirtualBox and run a Virtual Machine (VM) with a Ubuntu 12.04 image

* Download and Install VirtualBox from https://www.virtualbox.org/wiki/Downloads
* Download Ubuntu 12.04 image and unzip the image from http://virtualboxes.org/images/ubuntu/
* Create a new Virtual Machine using the unzipped .vdi file
** You can select the unzipped vdi file when you create a VM.
* Set RAM to 2048MB, and set networking to NAT mode
* Turn VM on and login to it: username: ubuntu, password:reverse

### Install Git

    sudo apt-get install git -y

### Clone devi from github

    git clone https://github.com/savi-dev/devi.git


### Install Devi on the newly created VM



  devi
  |
  + util

* First, download an Oracle JDK 7 from http://www.oracle.com/technetwork/java/javase/downloads/index.html to the 'util' folder.
* Second, open a 'savirc' file and modify JAVA_* variables based on your downloaded file.

