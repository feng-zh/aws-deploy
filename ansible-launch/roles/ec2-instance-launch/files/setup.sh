#!/bin/bash

service docker start

git clone https://github.com/feng-zh/aws-deploy.git /opt/ops/aws-deploy

cd /opt/ops/aws-deploy/ansible-launch

ansible-playbook playbooks/cloud-start.yml --vault-password-file=/opt/ops/.vault-password
