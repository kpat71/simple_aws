# Ansible for dummies

## Related Git repos

* <https://github.com/kpat71/simple_aws.git>
* <https://github.com/kpat71/ansible.git>

## Setup a nginx instance in AWS with Ansible

To set up an EC2 instance with nginx first clone the "simple_aws" repository.

```bash
git clone https://github.com/kpat71/simple_aws.git
```

Read `deploy.sh` and edit it according to your needs. By default the script will deploy a t3.nano Amazon Linux instance in eu-west-1 with ports 80,443 and 22 open to public internet.

Once done with your modifications execute the script to instantiate the environment. Notice that the UserData script is run which will automatically run the ansible playbook from the "ansible.git" repo.

## Additional info

### Best practise document

<https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html>

### UserData script for the EC2 instance

```bash
#!/bin/bash -xe
# Update
if [ -d '/etc/yum.repos.d' ]; then yum update -y; fi
if [ -f '/etc/debian_version' ]; then export DEBIAN_FRONTEND=noninteractive; fi
if [ -f '/etc/debian_version' ]; then apt-get update && apt-get upgrade -y; fi
if [ -f '/etc/debian_version' ]; then apt-get install python -y; fi
cd /tmp
# install PIP
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
if [ -d '/etc/yum.repos.d' ]; then python get-pip.py; fi
if [ -f '/etc/debian_version' ]; then python get-pip3.py; fi
# Install ansible
if [ -f '/etc/debian_version' ]; then pip install 'cryptography==2.4.2'; fi
pip install 'ansible==2.7.2'
# Install GIT client
if [ -f '/etc/debian_version' ]; then apt-get install -y git; fi
if [ -d '/etc/yum.repos.d' ]; then yum install -y git; fi
# Remove existing ansible installation
rm -rf /tmp/ansible
# Get Ansible files from github
git clone https://github.com/kpat71/ansible.git
cd /tmp/ansible
# Make log file for ansible logs
mkdir -p /var/log/ansible/
# Add variable to put log files to log file
export ANSIBLE_LOG_PATH=/var/log/ansible/ansible.log
#  RUN ansible playbook
ansible-playbook -i inventories/test/hosts site.yml
```

### Get facts from instance locally

```bash
ansible -m setup localhost
```
