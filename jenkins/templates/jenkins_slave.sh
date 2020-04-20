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

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo ‘export PATH=$HOME/bin:$PATH’ >> ~/.bashrc
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH
echo ‘export PATH=$HOME/bin:$PATH’ >> ~/.bashrc
