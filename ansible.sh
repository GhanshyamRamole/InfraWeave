#!/bin/bash
useradd itadmin
echo 111 | passwd --stdin itadmin
echo 111 | passwd --stdin ec2-user
echo "itadmin  ALL=(ALL)   NOPASSWD: ALL" >> /etc/sudoers
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
echo PermitRootLogin yes >> /etc/ssh/sshd_config
systemctl restart sshd
yum update -y
yum install ansible* -y
hostnamectl  set-hostname ansible
mkdir  /home/itadmin/punepro
echo [web] >> /home/itadmin/punepro/inventory
echo node1 >> /home/itadmin/punepro/inventory
echo node2 >> /home/itadmin/punepro/inventory
echo node3 >> /home/itadmin/punepro/inventory
echo [web:vars] >> /home/itadmin/punepro/inventory
echo ansible_port=22 >> /home/itadmin/punepro/inventory
echo ansible_user=itadmin >> /home/itadmin/punepro/inventory
echo ansible_password=111 >> /home/itadmin/punepro/inventory
echo [defaults]  >> /home/itadmin/punepro/ansible.cfg
echo inventory=/home/itadmin/punepro/inventory  >> /home/itadmin/punepro/ansible.cfg
echo remote_user=itadmin  >> /home/itadmin/punepro/ansible.cfg
echo host_key_checking=false  >> /home/itadmin/punepro/ansible.cfg
echo interpreter_python = auto_silent   >> /home/itadmin/punepro/ansible.cfg
echo [privilege_escalation]  >> /home/itadmin/punepro/ansible.cfg
echo become=yes  >> /home/itadmin/punepro/ansible.cfg
echo become_user=root  >> /home/itadmin/punepro/ansible.cfg
echo become_method=sudo  >> /home/itadmin/punepro/ansible.cfg
echo become_ask_pass=false  >> /home/itadmin/punepro/ansible.cfg
chown -R  itadmin:itadmin  /home/itadmin/punepro
cd /home/itadmin/punepro; ansible node1 -a "hostnamectl set-hostname node1.example.com"
cd /home/itadmin/punepro; ansible node2 -a "hostnamectl set-hostname node2.example.com"
cd /home/itadmin/punepro; ansible node3 -a "hostnamectl set-hostname node3.example.com"
