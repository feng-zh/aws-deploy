#!/bin/bash

yum upgrade -y

chkconfig docker on
service docker start

su - ops << EOF

git clone https://github.com/feng-zh/aws-deploy.git 

cd aws-deploy/ansible-launch

ansible-playbook playbooks/cloud-start.yml --vault-password-file=~/.vault-password

EOF
