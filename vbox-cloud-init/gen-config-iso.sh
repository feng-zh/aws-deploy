#!/bin/bash

# Pre-condition package: genisoimage

genisoimage -output cloud-init.iso -volid cidata -joliet -rock meta-data user-data network-config
