# Get Ubuntu AMI information 
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}




data "template_file" "consul_monitoring" {
  template = file("${path.module}/consul/templates/consul-agent.sh.tpl")

  vars = {
    consul_version = var.consul_version
    node_exporter_version = var.node_exporter_version
    prometheus_dir = var.prometheus_dir
    config = <<EOF
       "node_name": "monitoring-server-${count.index+1}",
       "enable_script_checks": true,
       "server": false
      EOF
    }
  }

# Allocate the EC2 monitoring instance
resource "aws_instance" "monitor" {
  count         = "${var.monitor_servers}"
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.monitor_instance_type}"

  subnet_id = "${aws_subnet.pubsub[2].id}"
  vpc_security_group_ids = [aws_security_group.monitor_sg.id]
  key_name               = "${var.default_keypair_name}"
  associate_public_ip_address = true

  tags = {
    Owner = var.owner
    Name  = "Monitor-${count.index+1}"
  }
    connection {
    type = "ssh"
    host = aws_instance.monitor[count.index].public_ip
    user = "ubuntu"
    private_key = tls_private_key.servers_key.private_key_pem
  }
  
  provisioner "file" {
    source      = "/Users/adarb/projects/final/monitoring"
    destination = "/home/ubuntu/"
  }

  user_data = <<-EOF
        #! /bin/bash
                sudo apt-get update -y
                sleep 30
                sudo chmod 777 /home/ubuntu/monitoring
                chmod +x /home/ubuntu/monitoring/inst_docker.sh
                chmod +x /home/ubuntu/monitoring/inst_node_exporter.sh
                /home/ubuntu/monitoring/inst_docker.sh
                /home/ubuntu/monitoring/inst_node_exporter.sh
                sudo chmod 666 /var/run/docker.sock
                sudo chmod 666 /home/ubuntu/monitoring/node_exporter.service
                cd /home/ubuntu/monitoring/compose && docker-compose down
                cd /home/ubuntu/monitoring/compose && docker-compose up -d              
                EOF
}