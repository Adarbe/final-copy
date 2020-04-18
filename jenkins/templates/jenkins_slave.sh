#!bin/bash
set -e

cd ~/.ssh/
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa 
chmod 600 id_rsa
chmod 600 id_rsa.pub
cat id_rsa.pub >> /home/ec2-user/.ssh/authorized_keys

sudo yum update -y
sudo yum install java-1.8.0 -y
sudo yum install docker git -y
sudo service docker start
sudo usermod -aG docker ec2-user

sudo yum install python-pip -y
sudo pip install awscli
sudo yum install git -y
sudo chmod 777 /var/lib/jenkins/
