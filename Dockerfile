FROM jenkins/jenkins:latest

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt



# WORKDIR /home/ubuntu/

# COPY inst_node_exporter.sh /usr/local/bin/inst_node_exporter.sh
# COPY node_exporter.service /usr/local/bin/node_exporter.service

# RUN chmod +x usr/local/bin/inst_node_exporter.sh
# RUN chmod +x usr/local/bin/node_exporter.service
# RUN usr/local/bin/inst_node_exporter.sh /usr/local/bin/node_exporter.service