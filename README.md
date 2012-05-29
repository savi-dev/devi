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

IMPORTANT: Be sure to carefully read `savi.sh` and any other scripts you execute before you run them, as they install software and may alter your networking configuration. We strongly recommend that you run `savi.sh` in a clean and disposable vm when you are first getting started. Please, see the installation guide in this file.

Installation
------------

## Install VirtualBox and run a Virtual Machine (VM) with a Ubuntu 12.04 image

* Download and Install VirtualBox from https://www.virtualbox.org/wiki/Downloads
* Download Ubuntu 12.04 image and unzip the image from http://virtualboxes.org/images/ubuntu/
* Create a new Virtual Machine using the unzipped .vdi file
(You can select the unzipped vdi file when you create a VM)
* Set RAM to 2048MB, and set networking to NAT mode
* Turn VM on and login to it: username: ubuntu, password:reverse
* Change the keyboard setting from Italian to English. (System Settings->Keyboard Layout).

### Install Git

    sudo apt-get install git -y

### Clone devi from github

    git clone https://github.com/savi-dev/devi.git


### Install Devi on the newly created VM
The devi directory structure is as follow:

      devi
      |
      + functions
      |
      + html
        |
        + localrc.html
        |
        + savi.html
        |
        + savirc.html
      |
      + localrc
      |
      + savirc
      |
      + savi.sh
      |
      + util


1. Download an Oracle JDK 7 to the `util` folder.

        http://www.oracle.com/technetwork/java/javase/downloads/index.html
    
2. Open a `savirc` file and modify `JAVA_*` variables based on your downloaded file.
3. Open a `savirc` file and set `GIT_USERNAME` and `GIT_EMAIL` of `https://review.savinetwork.ca`.
4. Create your ssh key and import your generated public key to the `https://review.savinetwork.ca`
5. Run a `savi.sh` in the devi.

        cd devi; ./savi.sh

Devi installs all required software and SAVI testbed (TB) based on the settings in `localrc` and `savirc` and run a main SAVI control webservice using `screen`.

### Test a SAVI TB Control Webservice
Open a web browser (Firefox) and go to the following URL.

        http://localhost:9080/ws/ControlService?wsdl

If you can see a WSDL, the SAVI TB Control Webservice works well.

TO DO
-----
* Add project-specific configurations to `savirc`.

