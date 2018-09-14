#!/bin/bash
# This is the entry point for configuring the system.
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
#####################################################

source functions.sh # load our functions
# copy functions to /etc
sudo cp -r functions.sh /etc/

# Check system setup: Are we running as root on Ubuntu 16.04 on a
# machine with enough memory?
# If not, this shows an error and exits.
source preflight.sh

# Ensure Python reads/writes files in UTF-8. If the machine
# triggers some other locale in Python, like ASCII encoding,
# Python may not be able to read/write files. This is also
# in the management daemon startup script and the cron script.

if ! locale -a | grep en_US.utf8 > /dev/null; then
# Generate locale if not exists
hide_output locale-gen en_US.UTF-8
fi

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Fix so line drawing characters are shown correctly in Putty on Windows. See #744.
export NCURSES_NO_UTF8_ACS=1

# Recall the last settings used if we're running this a second time.
if [ -f /etc/multipool.conf ]; then

# Load the old .conf file to get existing configuration options loaded
# into variables with a DEFAULT_ prefix.
cat /etc/multipool.conf | sed s/^/DEFAULT_/ > /tmp/multipool.prev.conf
source /tmp/multipool.prev.conf
rm -f /tmp/multipool.prev.conf
else
FIRST_TIME_SETUP=1
fi

#check for user
echo Installing needed packages for setup to continue...

if [ ! -f /usr/bin/dialog ] || [ ! -f /usr/bin/python3 ] || [ ! -f /usr/bin/pip3 ]; then
sudo apt-get -q -q update
apt_get_quiet install dialog python3 python3-pip || exit 1
fi
# Are we running as root?
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root. Please re-run like this:"
	echo
	echo "bash $0"
	echo
  else
  source first_user.sh
	exit
fi

# Ask the user the intial questions
source questions.sh

# Create the STORAGE_USER and STORAGE_ROOT directory if they don't already exist.
if ! id -u $STORAGE_USER >/dev/null 2>&1; then
sudo useradd -m $STORAGE_USER
fi
if [ ! -d $STORAGE_ROOT ]; then
sudo mkdir -p $STORAGE_ROOT
fi

# Save the global options in /etc/multipool.conf so that standalone
# tools know where to look for data.
echo 'STORAGE_USER='"${STORAGE_USER}"'
STORAGE_ROOT='"${STORAGE_ROOT}"'
PUBLIC_IP='"${PUBLIC_IP}"'
PUBLIC_IPV6='"${PUBLIC_IPV6}"'
PRIVATE_IP='"${PRIVATE_IP}"'' | sudo -E tee /etc/multipool.conf >/dev/null 2>&1

# Start service configuration.
source menu.sh

# Give fail2ban another restart. The log files may not all have been present when
# fail2ban was first configured, but they should exist now.
restart_service fail2ban

# Done.
echo
echo "-----------------------------------------------"
echo
echo Thank you for using the Ultimate Crypto-Server Setup Installer!
echo
echo To run this installer anytime simply type, multipool!
echo Donations for continued support of this script are welcomed at:
echo
echo BTC 33XUK3hzZxmAPBgh2JMmMuVVSCAtpK9eQX
echo BCH qp75x65svsuntmxze38sxqp47h4fqqgfyge5fgegah
echo ETH 0xF2654882a26C3a226eEFF02E652D3aFFA1Bb682A
echo LTC MTWpEuaLyj5AnvKxCKFh9fDbgsdNJgaECx
cd ~
