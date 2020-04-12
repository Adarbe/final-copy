#!/bin/bash
set -e

apt-get update -y
chmod 777 /home/ubuntu/monitoring
chmod +x /home/ubuntu/monitoring/inst_docker.sh
chmod +x /home/ubuntu/monitoring/inst_node_exporter.sh
/home/ubuntu/monitoring/inst_docker.sh
/home/ubuntu/monitoring/inst_node_exporter.sh
chmod 766 /var/run/docker.sock
chmod 766 /home/ubuntu/monitoring/node_exporter.service
cd /home/ubuntu/monitoring/compose && docker-compose down
cd /home/ubuntu/monitoring/compose && docker-compose up -d