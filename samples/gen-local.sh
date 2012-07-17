#!/bin/bash

# gen-local.sh generates localrc for devi It's an interactive script.
# Keep track of the devstack directory

set -e

OF_DIR=`dirname $0`

DEVSTACK_DIR=/home/savi/devstack
echo "Where is the devstack installed folder? [$DEVSTACK_DIR] "
read DEVSTACK_DIR_READ
if [ $DEVSTACK_DIR_READ ]; then
  DEVSTACK_DIR=$DEVSTACK_DIR_READ
fi

source $DEVSTACK_DIR/openrc demo demo
# Import common functions
source $DEVSTACK_DIR/functions

echo "What is your username for SAVI GIT?"
read GIT_USERNAME

echo "What is your email address for SAVI GIT?"
read GIT_EMAIL

HARDWARE_ENDPOINT=http://localhost:9090/ws/HardwareWebService
echo "What is an endpoint for Hardware webservice? [$HARDWARE_ENDPOINT]"
read HARDWARE_ENDPOINT_READ
if [ $HARDWARE_ENDPOINT_READ ]; then
  HARDWARE_ENDPOINT=$HARDWARE_ENDPOINT_READ
fi

KEYSTONE_ENDPOINT=$(keystone  catalog | grep 'adminURL' | grep '35357' | get_field 2)
echo "What is an endpoint for Identity? [$KEYSTONE_ENDPOINT]"
read KEYSTONE_ENDPOINT_READ
if [ $KEYSTONE_ENDPOINT_READ ]; then
  KEYSTONE_ENDPOINT=$KEYSTONE_ENDPOINT_READ
fi

NOVA_ENDPOINT=$(keystone  catalog | grep 'publicURL' | grep '8774' | get_field 2)
echo "What is an endpoint for Compute? [$NOVA_ENDPOINT]"
read NOVA_ENDPOINT_READ
if [ $NOVA_ENDPOINT_READ ]; then
  NOVA_ENDPOINT=$NOVA_ENDPOINT_READ
fi

SWIFT_ENDPOINT=$(keystone  catalog | grep 'publicURL' | grep '8080' | grep 'AUTH' | get_field 2)
echo "What is an endpoint for Storage? [$SWIFT_ENDPOINT]"
read SWIFT_ENDPOINT_READ
if [ $SWIFT_ENDPOINT_READ ]; then
  SWIFT_ENDPOINT=$SWIFT_ENDPOINT_READ
fi

GLANCE_ENDPOINT=$(keystone  catalog | grep 'publicURL' | grep '9292' | get_field 2)
echo "What is an endpoint for Image? [$GLANCE_ENDPOINT]"
read GLANCE_ENDPOINT_READ
if [ $GLANCEKEYSTONE_ENDPOINT_READ ]; then
  GLANCE_ENDPOINT=$GLANCE_ENDPOINT_READ
fi

QUANTUM_ENDPOINT=$(keystone  catalog | grep 'publicURL' | grep '9696' | get_field 2)
echo "What is an endpoint for Network? [$QUANTUM_ENDPOINT]"
read QUANTUM_ENDPOINT_READ
if [ $QUANTUMKEYSTONE_ENDPOINT_READ ]; then
  QUANTUM_ENDPOINT=$QUANTUM_ENDPOINT_READ
fi

cp $OF_DIR/devi-localrc localrc
sed -i -e 's/\${GIT_USERNAME}/'$GIT_USERNAME'/g' localrc
sed -i -e 's/\${GIT_EMAIL}/'$GIT_EMAIL'/g' localrc
echo 'HARDWARE_ENDPOINT='${HARDWARE_ENDPOINT} >> localrc
echo 'KEYSTONE_ENDPOINT='${KEYSTONE_ENDPOINT} >> localrc
echo 'NOVA_ENDPOINT='${NOVA_ENDPOINT} >> localrc
echo 'SWIFT_ENDPOINT='${SWIFT_ENDPOINT} >> localrc
echo 'GLANCE_ENDPOINT='${GLANCE_ENDPOINT} >> localrc
echo 'QUANTUM_ENDPOINT='${QUANTUM_ENDPOINT} >> localrc
echo 'DEVSTACK_DIR='${DEVSTACK_DIR} >> localrc

echo "localrc generated for devi"

echo "Now run ./savi.sh"
