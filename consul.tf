
# Create the user-data for the Consul server
data "template_file" "consul_server" {
  count    = var.consul_servers
  template = file("${path.module}/consul/templates/consul.sh.tpl")

  vars = {
    consul_version = var.consul_version
    node_exporter_version = var.node_exporter_version
    prometheus_dir = var.prometheus_dir
    config = <<EOF
      "node_name": "consul-server-${count.index +1}",
      "server": true,
      "bootstrap_expect": 3,
      "ui": true,
      "client_addr": "0.0.0.0",
      "telemetry": {
        "prometheus_retention_time": "10m"
      }
    EOF
  }
}

data "template_file" "consul_agent" {
  template = file("${path.module}/consul/templates/consulnew.sh.tpl")

vars = {
      consul_version = var.consul_version
      node_exporter_version = var.node_exporter_version
      prometheus_dir = var.prometheus_dir
      config = <<EOF
       "node_name": "final-consul-agent,
       "enable_script_checks": true,
       "server": false
      EOF
    }
}

# Create the Consul cluster
resource "aws_instance" "consul_server" {
  count                  = var.consul_servers
  availability_zone      = "${data.aws_availability_zones.available.names[count.index]}"
  subnet_id              = "${aws_subnet.pubsub[count.index].id}"
  ami                    = "ami-024582e76075564db"
  instance_type          = "t2.micro"
  key_name               = var.servers_keypair_name
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = ["${aws_security_group.final_consul.id}","${aws_security_group.monitor_sg.id}"]

  tags = {
    Name  = "consul-server-${count.index + 1}"
    consul_server = "true"
  }

  user_data = element(data.template_file.consul_server.*.rendered, count.index)
}








