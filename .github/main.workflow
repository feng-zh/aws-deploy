workflow "on dispatch" {
  on = "repository_dispatch"
  resolves = ["ansible"]
}

action "ansible-vars" {
  uses = "actions/bin/sh@master"
  secrets = ["EXTRA_VARS"]
  args = [".github/ansible_vars.sh"]
}

action "ansible" {
  needs = ["ansible-vars"]
  uses = "docker://williamyeh/ansible:alpine3"
  args = ["sh", "-c", "pip install boto; pip install boto3; ansible-playbook playbooks.yml -e @.extra_vars"]
}
