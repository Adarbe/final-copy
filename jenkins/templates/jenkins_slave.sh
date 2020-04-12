#!bin/bash
set -e
    ssh-keygen -q -t rsa -N '' -f ~/ubuntu/.ssh/id_rsa 2>/dev/null <<< y >/dev/null
    chmod 600 id_rsa
    chmod 600 id_rsa.pub
    cat id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys