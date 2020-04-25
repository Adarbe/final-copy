#!/bin/bash
set -e

sleep 30 
chmod 777 /home/ubuntu/monitoring
chmod +x /home/ubuntu/monitoring/inst_docker.sh
chmod +x /home/ubuntu/monitoring/inst_node_exporter.sh
/home/ubuntu/monitoring/inst_docker.sh
chmod 767 /var/run/docker.sock
cd /home/ubuntu/monitoring/compose && docker-compose down
cd /home/ubuntu/monitoring/compose && docker-compose up -d &&
--name=registrator &&
    --net=host &&
    --volume=/var/run/docker.sock:/tmp/docker.sock &&
      gliderlabs/registrator:latest &&
      consul://localhost:8500