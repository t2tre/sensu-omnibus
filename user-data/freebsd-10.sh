#!/bin/sh
env ASSUME_ALWAYS_YES=YES pkg bootstrap
pkg install -y sudo
pkg install -y security/ca_root_nss
echo 'ec2-user ALL=(ALL) NOPASSWD: ALL' > /usr/local/etc/sudoers.d/ec2-user
