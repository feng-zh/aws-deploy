workflow "on dispatch" {
  on = "repository_dispatch"
  resolves = ["ansible"]
}

action "ansible" {
  uses = "docker://williamyeh/ansible:alpine3"
  secrets = ["VAULT_PASSWORD"]
  args = ["sh", "-c", "cd ansible-launch; echo $VAULT_PASSWORD > .vault-password; pip install boto; pip install boto3; ansible-playbook playbooks/ansible-aws.yml --vault-password-file=.vault-password -e echo_ec2_ip=false"]
}