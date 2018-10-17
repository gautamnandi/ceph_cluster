#!/bin/bash
set -x
# output log of userdata to /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
apt-get -y update
apt-get -y install python-minimal
