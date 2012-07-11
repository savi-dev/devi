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

This version is only tested on Ubuntu 12.04. Use other versions at your risk.

Installation
------------
### Prerequisites
Before installing devi, you have to install openstack using `devstack` in your machine.

### How to install SAVI Testbed Control
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
      + samples
        |
        + localrc
        |
        + of
          |
          + devi-localrc
          |
          + gen-local.sh
      |
      + util

In project's root folder, run:

    samples/of/gen-local.sh

This scripts asks for some parameters, and generates the localrc for you. Then,
run devi to complete the installation:

    ./savi.sh

Devi installs all required software and SAVI Testbed (TB) based on the settings in `localrc` and `savirc` and run a main SAVI control webservice using `screen`.

### Test a SAVI TB Control Webservice
Open a web browser (Firefox) and go to the following URL.

        http://localhost:9080/ws/ControlService?wsdl

If you can see a WSDL, the SAVI TB Control Webservice works well.

# Example Setup

Suppose that we have a Control webservice, one resource webservice, Hardware,
and Openstack for cloud.

    @@@@@@@@@ Control @@@@@@@@    @@@@@@ Hardware @@@@@@
    |                        |----|9090 port           |
    |9080 port               |    @@@@@@@@@@@@@@@@@@@@@@
    |                        |
    |                        |    @@@@@ Openstack @@@@@@
    |                        |----|Identity            |
    |                        |----|Compute             |
    |                        |----|Storage             |
    |                        |----|Network             |
    |                        |----|Image               |
    @@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@

## Install devi

Run:

    samples/of/gen-local.sh

For our example, answer the question as below:

    Where is the installed folder? [/home/savi/devstack] 
    <devstack installation dir> 
    Please enter a root password for MySQL:
    <mysql password>
    What is your username for SAVI GIT?
    sample
    What is your username for SAVI GIT?
    sample
    What is your email address for SAVI GIT?
    sample@sample.org
    What is an endpoint for Hardware webservice? [http://localhost:9090/ws/HardwareWebService]
    <hardware webservice endpoint>	
    What is an endpoint for Hardware webservice? [http://localhost:9090/ws/HardwareWebService]
    <nova_endpoint>
    What is an endpoint for Storage? [http://192.168.123.201:8080/v1/AUTH_45ea9b19c3d94ad7887f64faa9d35faf]
    <swift endpoint>
    What is an endpoint for Identity? [http://192.168.123.201:35357/v2.0]
    <keystone endpoint>
    What is an endpoint for Image? [http://192.168.123.201:9292]
    <glance endpoint>
    What is an endpoint for Network? [http://192.168.123.201:9696/]
    <quantum endpoint>
    localrc generated for devi
    Now run ./savi.sh

## Test SAVI TB Control
In the installed folder of savi, go to the king/script,

### Authentication

* Get token

Run:

    savi_get_token

### Storage

* Get file

Run

    savi_get_file


* Put file

    savi_put_file

### Hardware
(TBD)
