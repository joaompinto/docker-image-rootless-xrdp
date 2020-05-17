#!/bin/sh

ln -s /dev/stdout /var/log/xrdp.log

/opt/app/sbin/xrdp-sesman
/opt/app/sbin/xrdp --nodaemon
