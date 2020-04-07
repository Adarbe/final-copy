data "template_file" "consul_monitoring" {
  template = file("${path.module}/consul/templates/consul-agent.sh.tpl")

  vars = {
    consul_version = var.consul_version
    node_exporter_version = var.node_exporter_version
    prometheus_dir = var.prometheus_dir
    config = <<EOF
       "node_name": "monitoring-server",
       "enable_script_checks": true,
       "server": false
      EOF
  }
}
data "template_file" "monitoring_consul_info" {
  template = file("${path.module}/monitoring/install_monitoring_server.sh.tpl")
}

data "template_file" "script_monitoring_server" {
  template = file("${path.module}/monitoring/monitoring.sh")
}

#Create the user-data for the monitoring server

data "template_cloudinit_config" "consul_monitoring_settings" {
  part {
    content = data.template_file.script_monitoring_server.rendered
  }
  part {
    content = data.template_file.consul_monitoring.rendered
  }
  part {
    content = data.template_file.monitoring_consul_info.rendered
  }
}


# Allocate the EC2 monitoring instance
resource "aws_instance" "monitor" {
  count         = "${var.monitor_servers}"
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.monitor_instance_type}"
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  subnet_id = "${aws_subnet.pubsub[2].id}"
  vpc_security_group_ids = ["${aws_security_group.monitor_sg.id}","${aws_security_group.final_consul.id}"]
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

  user_data = data.template_cloudinit_config.consul_monitoring_settings.rendered
}
