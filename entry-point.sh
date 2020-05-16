#!/bin/sh
export DISPLAY=:10
export HOME=/home/developer
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /passwd.template > /tmp/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

echo running
ln -s /dev/stdout /var/log/xrdp.log
ln -s /dev/stdout /var/log/xrdp-sesman.log

/opt/app/sbin/xrdp-sesman
/opt/app/sbin/xrdp --nodaemon
