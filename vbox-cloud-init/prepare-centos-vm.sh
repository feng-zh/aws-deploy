#!/bin/bash

# Pre-conditions: qemu-img, xz/unxz

# Download CentOS GenericCloud cloud image
wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2.xz

# Uncompress xz file
unxz CentOS-7-x86_64-GenericCloud.qcow2.xz

# Resize image from 8G to 20G
qemu-img resize CentOS-7-x86_64-GenericCloud.qcow2 +12G

# Convert image qcow2 format to vmkd
qemu-img convert -f qcow2 CentOS-7-x86_64-GenericCloud.qcow2 -O vmdk CentOS-7-x86_64-GenericCloud.vmdk
