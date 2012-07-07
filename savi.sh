#!/usr/bin/env bash

# This script was written based on ``stack.sh`` from devStack.

# ``savi.sh`` is an opinionated SAVI testbed (TB) developer installation.
# It installs and configures SAVI TB Core logic (**bloor**, **cheetah**,
# **yorkdale**, **moon**, **wilson**, **griffin**), SAVI TB Resource Webservices
# (**camel**, **coala**, **crane**, **horse**), and SAVI TB clients (**king**,
# **queen**, **dundas**, **college**).

# Before running this script, you have to import your public key into review.savinetwork.ca.

# This script allows you to specify configuration options of what git
# repositories to use, enabled services, network configuration and various
# passwords. 
# It downloads and installs all required software including **MySQL**, **JDK**, 
# **Python**, **Apache Ant**, **Apache Ivy**, and **Yak** tool for SAVI TB 
# development.

# To keep this script simple we assume you are running on an **Ubuntu 11.10
# Oneiric** or **Ubuntu 12.04 Precise** machine.  It should work in a VM or
# physical server.

# Keep track of the devi directory
TOP_DIR=$(cd $(dirname "$0") && pwd)

# Import common functions
source $TOP_DIR/functions

# Determine what system we are running on.  This provides ``os_VENDOR``,
# ``os_RELEASE``, ``os_UPDATE``, ``os_PACKAGE``, ``os_CODENAME``
GetOSVersion

# Translate the OS version values into common nomenclature
if [[ "$os_VENDOR" =~ (Ubuntu) ]]; then
    # 'Everyone' refers to Ubuntu releases by the code name adjective
    DISTRO=$os_CODENAME
elif [[ "$os_VENDOR" =~ (Fedora) ]]; then
    # For Fedora, just use 'f' and the release
    DISTRO="f$os_RELEASE"
else
    # Catch-all for now is Vendor + Release + Update
    DISTRO="$os_VENDOR-$os_RELEASE.$os_UPDATE"
fi

# Settings
# ========

# ``savi.sh`` is customizable through setting environment variables.  If you
# want to override a setting you can set and export it::
#
#     export MYSQL_PASSWORD=anothersecret
#     ./savi.sh
#
# You can also pass options on a single line ``MYSQL_PASSWORD=simple ./savi.sh``
#
# Additionally, you can put any local variables into a ``localrc`` file::
#
#     MYSQL_USER=root
#     MYSQL_PASSWORD=anothersecret
#
# We try to have sensible defaults, so you should be able to run ``./savi.sh``
# in most cases.
#
# Devi distributes ``savi`` which contains locations for the SAVI TB
# repositories and branches to configure.  ``savirc`` sources ``localrc`` to
# allow you to safely override those settings without being overwritten
# when updating Devi.
if [[ ! -r $TOP_DIR/savirc ]]; then
    echo "ERROR: missing $TOP_DIR/savirc - did you grab more than just savi.sh?"
    exit 1
fi
source $TOP_DIR/savirc

# Destination path for installation ``DEST``
DEST=${DEST:-/opt/savi}


# Sanity Check
# ============

# Warn users who aren't on an explicitly supported distro.
if [[ ! ${DISTRO} =~ (oneiric|precise|f16) ]]; then
    echo "WARNING: this script has been tested on oneiric, precise and f16"
    if [[ "$FORCE" != "yes" ]]; then
        echo "If you wish to run this script anyway run with FORCE=yes"
        exit 1
    fi
fi

# Check to see if we are already running Devi
if type -p screen >/dev/null && screen -ls | egrep -q "[0-9].savi"; then
    echo "You are already running a savi.sh session."
    echo "To rejoin this session type 'screen -x savi'."
    echo "To destroy this session, kill the running screen."
    exit 1
fi

# Generic helper to configure passwords
function read_password {
    set +o xtrace
    var=$1; msg=$2
    pw=${!var}

    localrc=$TOP_DIR/localrc

    # If the password is not defined yet, proceed to prompt user for a password.
    if [ ! $pw ]; then
        # If there is no localrc file, create one
        if [ ! -e $localrc ]; then
            touch $localrc
        fi

        # Presumably if we got this far it can only be that our localrc is missing
        # the required password.  Prompt user for a password and write to localrc.
        echo ''
        echo '################################################################################'
        echo $msg
        echo '################################################################################'
        echo "This value will be written to your localrc file so you don't have to enter it "
        echo "again.  Use only alphanumeric characters."
        echo "If you leave this blank, a random default value will be used."
        pw=" "
        while true; do
            echo "Enter a password now:"
            read -e $var
            pw=${!var}
            [[ "$pw" = "`echo $pw | tr -cd [:alnum:]`" ]] && break
            echo "Invalid chars in password.  Try again:"
        done
        if [ ! $pw ]; then
            pw=`openssl rand -hex 10`
        fi
        eval "$var=$pw"
        echo "$var=$pw" >> $localrc
    fi
    set -o xtrace
}

# Install required software for SAVI TB: **MySQL**, **Java Development Kit 7**,
# **Python 2.7**, **Apache Ant**, **Apache Ivy**, and **Yak** tool.

# MySQL
# ----------------

# We configure a SAVI TB control webservice to use MySQL as their
# database server.

# By default this script will install and configure MySQL.  If you want to
# use an existing server, you can pass in the user/password/host parameters.
# You will need to send the same ``MYSQL_PASSWORD`` to every host if you are doing
# a multi-node DevStack installation.
MYSQL_HOST=${MYSQL_HOST:-localhost}
MYSQL_USER=${MYSQL_USER:-root}
read_password MYSQL_PASSWORD "ENTER A PASSWORD TO USE FOR MYSQL."

# NOTE: Don't specify /db in this string so we can use it for multiple services
BASE_SQL_CONN=${BASE_SQL_CONN:-mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST}

# Log files
# ---------

# Set up logging for savi.sh
# Set LOGFILE to turn on logging
# We append '.xxxxxxxx' to the given name to maintain history
# where xxxxxxxx is a representation of the date the file was created
if [[ -n "$LOGFILE" || -n "$SCREEN_LOGDIR" ]]; then
    LOGDAYS=${LOGDAYS:-7}
    TIMESTAMP_FORMAT=${TIMESTAMP_FORMAT:-"%F-%H%M%S"}
    CURRENT_LOG_TIME=$(date "+$TIMESTAMP_FORMAT")
fi

if [[ -n "$LOGFILE" ]]; then
    # First clean up old log files.  Use the user-specified LOGFILE
    # as the template to search for, appending '.*' to match the date
    # we added on earlier runs.
    LOGDIR=$(dirname "$LOGFILE")
    LOGNAME=$(basename "$LOGFILE")
    mkdir -p $LOGDIR
    find $LOGDIR -maxdepth 1 -name $LOGNAME.\* -mtime +$LOGDAYS -exec rm {} \;

    LOGFILE=$LOGFILE.${CURRENT_LOG_TIME}
    # Redirect stdout/stderr to tee to write the log file
    exec 1> >( tee "${LOGFILE}" ) 2>&1
    echo "savi.sh log $LOGFILE"
    # Specified logfile name always links to the most recent log
    ln -sf $LOGFILE $LOGDIR/$LOGNAME
fi

# Set up logging of screen windows
# Set SCREEN_LOGDIR to turn on logging of screen windows to the
# directory specified in SCREEN_LOGDIR, we will log to the the file
# screen-$SERVICE_NAME-$TIMESTAMP.log in that dir and have a link
# screen-$SERVICE_NAME.log to the latest log file.
# Logs are kept for as long specified in LOGDAYS.
if [[ -n "$SCREEN_LOGDIR" ]]; then
    # We make sure the directory is created.
    if [[ -d "$SCREEN_LOGDIR" ]]; then
        # We cleanup the old logs
        find $SCREEN_LOGDIR -maxdepth 1 -name screen-\*.log -mtime +$LOGDAYS -exec rm {} \;
    else
        mkdir -p $SCREEN_LOGDIR
    fi
fi

# So that errors don't compound we exit on any errors so you see only the
# first error that occurred.
trap failed ERR
failed() {
    local r=$?
    set +o xtrace
    [ -n "$LOGFILE" ] && echo "${0##*/} failed: full log in $LOGFILE"
    exit $r
}

# Print the commands being run so that we can see the command that triggers
# an error.  It is also useful for following along as the install occurs.
set -o xtrace


# create the destination directory and ensure it is writable by the user
mkdir -p $DEST
if [ ! -w $DEST ]; then
    chown `whoami` $DEST
fi

# Install Packages
# ================
#
# SAVI uses a fair number of other projects.
# Python
# ------
echo "[${PROJECT}] Installing a python tool"
sudo apt-get install python -y
sudo apt-get install python-setuptools -y

# Screen
# ------
echo "[${PROJECT}] Installing a screen utility"
sudo apt-get install screen -y

# Yak tool
# ----------------
# If yak is installed, skip this process, otherwise, download it from 
# a SAVI release site.
echo
echo "[${PROJECT}] Yak tool"
echo
if [[ ! -f $TOP_DIR/${YAK_FULLFILE} ]]; then
  echo "[${PROJECT}] There is no ${YAK_FILE} in ${TOP_DIR}/${UTIL_DIR}"
  echo "[${PROJECT}] Downloading... ${YAK_FILE} from ${YAK_ADDRESS}"
  cd ${UTIL_DIR}; wget ${YAK_ADDRESS}
fi

# Setup a yak tool so it is installed into python path.
echo
echo "[${PROJECT}] Installing a yak tool"
echo
cd $TOP_DIR/$UTIL_DIR; tar xvzf ${YAK_FILE}; cd ${YAK_DIR}; sudo python setup.py develop; cd ..;

# Git
# ----------------
# Git setting. Set your username and email
echo
echo "[${PROJECT}] Setting a git username and email"
echo
git config --global user.name ${GIT_USERNAME}
git config --global user.email ${GIT_EMAIL}

# JDK
# ----------------
# Java Development Kit
# **Warning**: Download Oracle Java 7 from http://www.oracle.com/technetwork/java/javase/downloads/index.html.
echo "[${PROJECT}] Installing JDK"
if [[ ! -d ${JAVA_IHOME} ]]; then
  echo "[${PROJECT}] Removing openjdk-6 if there is an installed openjdk."
  sudo apt-get autoremove openjdk-6-jre-headless
  echo "[${PROJECT}] Downloading Oracle java 7"
  if [[ ! -f ${TOP_DIR}/${UTIL_DIR}/${JAVA_PKG_NAME} ]]; then
    echo "[${PROJECT}] There is no ${JAVA_PKG_NAME} in ${TOP_DIR}/${UTIL_DIR}"
    echo "[${PROJECT}] Please, download JDK-${JAVA_VERSION} from http://www.oracle.com/technetwork/java/javase/downloads/index.html"
    exit 1;
  fi

  # If there is an installed JDK, skip this process.
  echo "[${PROJECT}] Checking an installed JDK"
  if [[ ! -d ${JAVA_IHOME} ]]; then
    echo "[${PROJECT}] Copying ${JAVA_PKG_NAME} to ${JAVA_INSTALL_DIR}"
    cd ${TOP_DIR}/${UTIL_DIR}; tar xvzf ${JAVA_PKG_NAME}; sudo mv ${JAVA_DIR} ${JAVA_INSTALL_DIR}
  fi

  # If a JAVA_HOME environment variable is different to the installed JAVA, add it to a .bashrc file.
  if [[ "$JAVA_IHOME" = "$JAVA_HOME" ]]; then
    echo "[${PROJECT}] JAVA_HOME is set and same to the installed one."
  else
    echo "[${PROJECT}] JAVA_HOME is set but different to the installed one."
    echo "[${PROJECT}] JAVA_HOME and PATH in .bashrc are changing..."
    echo "" >> $HOME/.bashrc
    echo "# Setting JAVA_HOME" >> $HOME/.bashrc
    echo "JAVA_HOME=$JAVA_IHOME" >> $HOME/.bashrc
    echo "PATH=\$PATH:\$JAVA_HOME/bin" >> $HOME/.bashrc
    echo "export JAVA_HOME" >> $HOME/.bashrc
    echo "export PATH" >> $HOME/.bashrc
    source $HOME/.bashrc
  fi
else
  echo "[${PROJECT}] There is an installed JAVA in $JAVA_INSTALL_DIR"
fi
export JAVA_HOME=$JAVA_IHOME
export PATH=$PATH:$JAVA_HOME/bin

# Apache Ant and Ivy
# ----------------
# Apache Ant
# Download and install Apache Ivy.
echo "[${PROJECT}] Apache Ant tool"
if [[ ! -d ${ANT_IHOME} ]]; then
  echo "[${PROJECT}] There is no installed Ant in $ANT_INSTALL_DIR"
  if [[ ! -d "$ANT_INSTALL_DIR" ]]; then
    sudo mkdir $ANT_INSTALL_DIR
  fi
  if [[ ! -f $TOP_DIR/${ANT_FULLFILE} ]]; then
    echo "[${PROJECT}] There is no ${ANT_FILE} in ${TOP_DIR}/${UTIL_DIR}"
    echo "[${PROJECT}] Downloading... ${ANT_FILE} from ${ANT_ADDRESS}"
    cd ${TOP_DIR}/${UTIL_DIR}; wget ${ANT_ADDRESS}
  fi
  echo "[${PROJECT}] Installing an Ant tool" 
  cd $TOP_DIR/$UTIL_DIR; tar xvzf ${ANT_FILE}; sudo mv ${ANT_DIR} $ANT_INSTALL_DIR;
  # If a ANT_HOME environment variable is different to the installed ANT, add it to a .bashrc file.
  if [[ "$ANT_IHOME" = "$ANT_HOME" ]]; then
    echo "[${PROJECT}] ANT_HOME is set and same to the installed one."
  else
    echo "[${PROJECT}] ANT_HOME is set but different to the installed one."
    echo "[${PROJECT}] ANT_HOME and PATH in .bashrc are changing..."
    echo "" >> $HOME/.bashrc
    echo "# Setting ANT_HOME" >> $HOME/.bashrc
    echo "ANT_HOME=$ANT_IHOME" >> $HOME/.bashrc
    echo "PATH=\$PATH:\$ANT_HOME/bin" >> $HOME/.bashrc
    echo "export ANT_HOME" >> $HOME/.bashrc
    echo "export PATH" >> $HOME/.bashrc
    source $HOME/.bashrc
  fi
else
  echo "[${PROJECT}] There is an installed Ant in $ANT_INSTALL_DIR"
fi
export ANT_HOME=$ANT_IHOME
export PATH=$PATH:$ANT_HOME/bin

# Download and install Apache Ivy.
echo "[${PROJECT}] Apache Ivy tool"
if [[ ! -f $IVY_INSTALL_DIR/${IVY_FILE} ]]; then
  echo "[${PROJECT}] There is no ${IVY_FILE} in ${ANT_IHOME}/lib"
  if [[ ! -f $TOP_DIR/${IVY_FULLFILE} ]]; then
    echo "[${PROJECT}] There is no ${IVY_PKG_FILE} in ${TOP_DIR}/${UTIL_DIR}"
    echo "[${PROJECT}] Downloading... ${IVY_FILE} from ${IVY_ADDRESS}"
    cd ${TOP_DIR}/${UTIL_DIR}; wget ${IVY_ADDRESS}
  fi

  # Setup ivy tool so it is installed into ant path
  echo "[${PROJECT}] Installing a ivy tool"
  cd $TOP_DIR/$UTIL_DIR; tar xvzf ${IVY_PKG_FILE}; cd ${IVY_DIR}; sudo cp ivy-${IVY_VERSION}.jar $IVY_INSTALL_DIR; cd ..; rm -rf ${IVY_DIR}
fi

# SAVI TB service
# ----------------
# Clone all enabled packages from SAVI repository
if is_service_enabled cheetah ; then
    # SAVI TB web service
  cd $DEST; export GITVI_USER=$GIT_USERNAME; gitvi clone $CHEETAH_PRJ
fi
if is_service_enabled horse ; then
    # SAVI HW Resource web service
  cd $DEST; export GITVI_USER=$GIT_USERNAME; gitvi clone $HORSE_PRJ
fi
if is_service_enabled king ; then
    # SAVI TB CLI client
  cd $DEST; export GITVI_USER=$GIT_USERNAME; gitvi clone $KING_PRJ
fi
if is_service_enabled college ; then
    # SAVI HW Resource CLI client
  cd $DEST; export GITVI_USER=$GIT_USERNAME; gitvi clone $COLLEGE_PRJ
fi
# MySQL
# ----------------
if is_service_enabled mysql; then

    if [[ "$os_PACKAGE" = "deb" ]]; then
        # Seed configuration with mysql password so that apt-get install doesn't
        # prompt us for a password upon install.
        cat <<MYSQL_PRESEED | sudo debconf-set-selections
mysql-server-5.1 mysql-server/root_password password $MYSQL_PASSWORD
mysql-server-5.1 mysql-server/root_password_again password $MYSQL_PASSWORD
mysql-server-5.1 mysql-server/start_on_boot boolean true
MYSQL_PRESEED
    fi

    # while ``.my.cnf`` is not needed for SAVI to function, it is useful
    # as it allows you to access the mysql databases via ``mysql nova`` instead
    # of having to specify the username/password each time.
    if [[ ! -e $HOME/.my.cnf ]]; then
        cat <<EOF >$HOME/.my.cnf
[client]
user=$MYSQL_USER
password=$MYSQL_PASSWORD
host=$MYSQL_HOST
EOF
        chmod 0600 $HOME/.my.cnf
    fi

    # Install and start mysql-server
    install_package mysql-server
    if [[ "$os_PACKAGE" = "rpm" ]]; then 
        # RPM doesn't start the service
        start_service mysqld
        # Set the root password - only works the first time
        sudo mysqladmin -u root password $MYSQL_PASSWORD || true 
    fi   
    # Update the DB to give user ‘$MYSQL_USER’@’%’ full control of the all databases:
    sudo mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h127.0.0.1 -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' identified by '$MYSQL_PASSWORD';"

    # Edit /etc/mysql/my.cnf to change ‘bind-address’ from localhost (127.0.0.1) to any (0.0.0.0) and restart the mysql service:
    if [[ "$os_PACKAGE" = "deb" ]]; then 
        MY_CNF=/etc/mysql/my.cnf
        MYSQL=mysql
    else 
        MY_CNF=/etc/my.cnf
        MYSQL=mysqld
    fi   
    sudo sed -i 's/127.0.0.1/0.0.0.0/g' $MY_CNF
    restart_service $MYSQL
fi

# Create a database specified in `SAVI_DATABASE` in `savirc` based on a dump file located in a yorkdale project.
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD < $SAVI_DBFILE

# Build SAVI TB Projects
# =============

# Build all SAVI TB projects
if is_service_enabled cheetah ; then
    cd $DEST/$CHEETAH; ant dist
fi
if is_service_enabled horse ; then
    cd $DEST/$HORSE; ant dist
fi
if is_service_enabled king ; then
    cd $DEST/$KING; ant dist
fi
if is_service_enabled college ; then
    cd $DEST/$COLLEGE; ant dist
fi

# Launch Services
# ===============

# Only run the services specified in ``ENABLED_SERVICES``

if [ -z "$SCREEN_HARDSTATUS" ]; then
    SCREEN_HARDSTATUS='%{= .} %-Lw%{= .}%> %n%f %t*%{= .}%+Lw%< %-=%{g}(%{d}%H/%l%{g})'
fi

# These two function `screen_rc` and `screen_it` from 'stack.sh' in devStack.
# Our screenrc file builder
function screen_rc {
    SCREENRC=$TOP_DIR/savi-screenrc
    if [[ ! -e $SCREENRC ]]; then
        # Name the screen session
        echo "sessionname savi" > $SCREENRC
        # Set a reasonable statusbar
        echo "hardstatus alwayslastline '$SCREEN_HARDSTATUS'" >> $SCREENRC
        echo "screen -t savi bash" >> $SCREENRC
    fi
    # If this service doesn't already exist in the screenrc file
    if ! grep $1 $SCREENRC 2>&1 > /dev/null; then
        NL=`echo -ne '\015'`
        echo "screen -t $1 bash" >> $SCREENRC
        echo "stuff \"$2$NL\"" >> $SCREENRC
    fi
}

# Our screen helper to launch a service in a hidden named screen
function screen_it {
    NL=`echo -ne '\015'`
    if is_service_enabled $1; then
        # Append the service to the screen rc file
        screen_rc "$1" "$2"

        screen -S savi -X screen -t $1
        # sleep to allow bash to be ready to be send the command - we are
        # creating a new window in screen and then sends characters, so if
        # bash isn't running by the time we send the command, nothing happens
        sleep 1.5

        if [[ -n ${SCREEN_LOGDIR} ]]; then
            screen -S savi -p $1 -X logfile ${SCREEN_LOGDIR}/screen-${1}.${CURRENT_LOG_TIME}.log
            screen -S savi -p $1 -X log on
            ln -sf ${SCREEN_LOGDIR}/screen-${1}.${CURRENT_LOG_TIME}.log ${SCREEN_LOGDIR}/screen-${1}.log
        fi
        screen -S savi -p $1 -X stuff "$2$NL"
    fi
}

# create a new named screen to run processes in
screen -d -m -S savi -t savi -s /bin/bash
sleep 1
# set a reasonable statusbar
screen -r savi -X hardstatus alwayslastline "$SCREEN_HARDSTATUS"

# SAVI TB Control Service
# ------------------------

# launch the bloor service
if is_service_enabled cheetah; then
    screen_it cheetah "cd ${DEST}/${CHEETAH}; java -jar dist/cheetah-0.2.jar"
fi
if is_service_enabled horse; then
    screen_it horse "cd ${DEST}/${HORSE}; java -jar dist/horse-0.1.jar"
fi
