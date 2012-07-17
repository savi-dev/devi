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
* To drop a database 'savicontroldb' and restore a database dump
* To run using screen
* To test using examples

IMPORTANT: Be sure to carefully read `savi.sh` and any other scripts you execute before you run them, as they install software and may alter your networking configuration. We strongly recommend that you run `savi.sh` in a clean and disposable vm when you are first getting started. Please, see the installation guide in this file.

This version is only tested on Ubuntu 12.04. Use other versions at your risk.

Installation
------------
### Prerequisites
Before installing devi, you have to install openstack using [devstack](http://www.devstack.org) in your machine.

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
        + devi-localrc
        |
        + gen-local.sh
      |
      + util

In project's root folder, run:

    samples/gen-local.sh

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

    samples/gen-local.sh

For our example, answer the question as below:

    Where is the installed folder? [/home/savi/devstack] 
    <devstack installation dir> 
    Please enter a root password for MySQL:
    <mysql password>
    What is your username for SAVI GIT?
    sample
    What is your email address for SAVI GIT?
    sample@sample.org
    What is an endpoint for Hardware webservice? [http://localhost:9090/ws/HardwareWebService]
    <hardware webservice endpoint>	
    What is an endpoint for Identity? [http://192.168.123.201:35357/v2.0]
    <keystone endpoint>
    What is an endpoint for Image? [http://192.168.123.201:9292]
    <glance endpoint>
    What is an endpoint for Network? [http://192.168.123.201:9696/]
    <quantum endpoint>
    localrc generated for devi
    Now run ./savi.sh

## Test SAVI TB Control
In the installed folder of savi (`~/savi`), go to the king/script,

**NOTE**: For your convenience, devi provides screens for executing scripts. If you are familiar with `screen', you can see clients by running the following command:

    screen -r savi

king is a client for SAVI TB Control and college is a client for Hardware resource.

First of all, you have to run the following command for setting environment variables for scripts. You can edit it for your test.

    source savi_env.sh

There are following environment variables.

    CONTROL_WSDL: SAVI TB Control Webservice address
    SAVI_JAR: SAVI TB Control client jar file path
    SAVI_USER: SAVI TB Control user name
    SAVI_PASSWORD: SAVI TB Control password for the given user
    SAVI_TOKEN: SAVI TB Control token for the given user and password
    SAVI_PROJECT: SAVI TB Control project name
    SAVI_Location: SAVI TB Control node location name
 
### Authentication

In order to get a token from SAVI TB Control, run:

    savi_get_token

It returns a token and expiration date for the given user.

    http://localhost:9080/ws/ControlService?wsdl
    Token : 9fa6d779481b4ed7ba3820d1fd76eb1a
    ExpirationDate : null
    Auth is  successful

### Storage

In order to put a file to storage

    savi_put_file <token> <filename> <expired time>

It returns a tempUrl for putting the file. You can put your file via the tempUrl. 

In order to get a file from a storage

    savi_get_file <token> <filename> <expired time>

It returns a tempUrl for getting the file. You can get the file via the tempUrl.


### Hardware

In SAVI TB Control, we are providing a client for hardware resources such as `FPGA` or `NetFPGA`.
In the installed folder of savi (`~/savi`), go to the college/script,

First of all, you have to run the following command for setting environment variables for scripts. You can edit it for your test.

    source savi_env.sh

There are following environment variables.

    CONTROL_WSDL: SAVI TB Control Webservice address
    SAVI_HW_JAR: SAVI TB Control Hardware resource client jar file path
    SAVI_USER: SAVI TB Control user name
    SAVI_PASSWORD: SAVI TB Control password for the given user
    SAVI_TOKEN: SAVI TB Control token for the given user and password
    SAVI_PROJECT: SAVI TB Control project name
    SAVI_Location: SAVI TB Control node location name
    SAVI_NETWORK: SAVI TB Control network name

In order to initialize a hardware resource

    savi_hw_init

In order to show a list of hardware resources
 
    savi_hw_list

In order to get the given hardware resource

    savi_hw_get <hardware UUID>

In order to release the given hardware resource

    savi_hw_rel <hardware UUID>

In order to program a Hardware resource

    savi_hw_prog <hardware UUID> <image UUID>

In order to show a status of the given hardware resource

    savi_hw_stat <hardware UUID>

In order to read a register from the given hardware resource
 
    savi_hw_read_res <hardware UUID>

In order to write a register value to the given hardware resource

    savi_hw_write_res <hardware UUID> <register value>

In order to attach the given hardware resource to the given network

    savi_hw_plug_attach <hardware UUID> <hardware port UUID> <network UUID>

In order to dettach the given hardware resource from the given network

    savi_hw_unplug_attach <hardware UUID> <hardware port UUID> <network UUID> <network port UUID>
