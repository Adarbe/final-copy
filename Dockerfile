FROM jenkins/jenkins:latest

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt

#ENV CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins.yaml

#COPY jenkins.yaml /home/ubuntu/jenkins_home/jenkins.yaml

#VOLUME ./config:/var/jenkins_conf



