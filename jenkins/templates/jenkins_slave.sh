#!bin/bash
set -e

tee /etc/profile.d/custom.lang.sh <<EOF >/dev/null  
## US English ##
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_COLLATE=C
export LC_CTYPE=en_US.UTF-8
EOF

source /etc/profile.d/custom.lang.sh

sudo yum update -y
sudo yum install java-1.8.0 -y
sudo yum install docker git -y
sudo service docker start
sudo usermod -aG docker ec2-user

sudo yum install python-pip -y
sudo pip install awscli
sudo yum install git -y

sudo ssh-keygen -q -t rsa -N '' -f /home/ec2-user/.ssh/id_rsa 
sudo chmod 600 /home/ec2-user/.ssh/id_rsa
sudo chmod 600 /home/ec2-user/.ssh/id_rsa.pub
sudo cat id_rsa.pub >> /home/ec2-user/.ssh/authorized_keys

yum install -y kubectl
sudo yum search nload
sudo install nload

sudo yum -y install bash-completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc

curl -L https://get.armory.io/halyard/install/latest/macos/InstallArmoryHalyard.sh > InstallArmoryHalyard.sh 
sudo bash InstallArmoryHalyard.sh --version latest
