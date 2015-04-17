#!/bin/sh
sudo apt-get update
sudo apt-get install -y openssh-server git ansible 

git clone https://github.com/jivoi/ansible-localhost.git
cd  ansible-localhost
ansible-playbook playbook.yml -i hosts --ask-sudo-pass