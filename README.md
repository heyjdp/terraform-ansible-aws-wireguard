# Terraform Ansible AWS Wireguard - personal VPN server

0. Make sure Ansible is installed:
 - https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

1. Make sure Terraform is installed: 
 - https://learn.hashicorp.com/tutorials/terraform/install-cli

2. Generate a new key pair:

```bash
cd <project-root>
ssh-keygen -t ed25519 -f devops_aws_key -c username@example.org
chmod 400 devops_aws_key*
```

3. Make sure your AWS credentials exist in this form:

```bash
cat $HOME/.aws/credentials
[aws]
aws_access_key_id = XXXXXXXXXX
aws_secret_access_key = YYYYYYYYYY
```

3. Run the project

```bash
cd src
terraform init
terraform plan
terraform apply
```
