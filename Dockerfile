FROM jenkins/jenkins:lts
EXPOSE 8080

USER root
WORKDIR /tmp


ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    apt-utils \
    python3 \
    python3-dev \
  && rm -rf /var/lib/apt/lists/* \
  && apt -qyy clean

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

RUN chmod 755 ./kubectl
RUN mv ./kubectl /usr/local/bin

RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
RUN chmod +x ./aws-iam-authenticator
RUN mv ./aws-iam-authenticator /usr/local/bin

RUN wget https://bootstrap.pypa.io/get-pip.py -O - | python3

USER jenkins
WORKDIR /

RUN pip3 install --user botocore
RUN pip3 install --user colorama

USER root
RUN pip3 install awscli

USER jenkins

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt

USER jenkins
