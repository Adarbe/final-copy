
# Create the user-data for the Consul server
data "template_file" "consul_server" {
  count    = var.consul_servers
  template = file("${path.module}/consul/templates/consul.sh.tpl")

  vars = {
    consul_version = var.consul_version
    prometheus_dir = var.prometheus_dir
    node_exporter_version = var.node_exporter_version
    config = <<EOF
      "node_name": "consul-server-${count.index +1}",
      "server": true,
      "bootstrap_expect": 3,
      "ui": true,
      "client_addr": "0.0.0.0",
      EOF
  }
}


# Create the Consul cluster
resource "aws_instance" "consul_server" {
  count                  = var.consul_servers
  availability_zone      = "${data.aws_availability_zones.available.names[count.index]}"
  subnet_id              = "${aws_subnet.pubsub[count.index].id}"
  ami                    = var.ami
  instance_type          = "t2.micro"
  key_name               = var.servers_keypair_name
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = ["${aws_security_group.final_consul.id}"]

  tags = {
    Name  = "consul-server-${count.index + 1}"
    consul_server = "true"
  }

  user_data = element(data.template_file.consul_server.*.rendered, count.index)
}



data "template_file" "consul_client" {
  count = 1
  template = file("${path.module}/consul/templates/consul-agent.sh.tpl")

  vars = {
    prometheus_dir = var.prometheus_dir
    node_exporter_version = var.node_exporter_version
    config = <<EOF
       "node_name": "jenkins-server-1",
       "enable_script_checks": true,
       "server": false
      EOF
    }
  }

# data "template_file" "consul_client_linux" {
#   count = 1
#   template = file("${path.module}/consul/templates/consul-agent-linux.sh.tpl")

#   vars = {
#     prometheus_dir = var.prometheus_dir
#     node_exporter_version = var.node_exporter_version
#     config = <<EOF
#        "node_name": "jenkins-server-1",
#        "enable_script_checks": true,
#        "server": false
#       EOF
#     }
#   }

# data "template_file" "consul_client" {
#   count    = var.consul_servers
#   template = file("${path.module}/consul/templates/consul.sh.tpl")

#   vars = {
#       consul_version = var.consul_version
#       config = <<EOF
#        "node_name": "final-client-${count.index+1}",
#        "enable_script_checks": true,
#        "server": false
#       EOF
#   }
# }



# resource "aws_instance" "consul_client" {
#   count = var.clients
  
#   ami  = var.ami
#   instance_type = "t2.micro"
#   key_name = var.servers_keypair_name
#   availability_zone      = "${data.aws_availability_zones.available.names[count.index]}"
#   iam_instance_profile   = aws_iam_instance_profile.consul-join.name
#   vpc_security_group_ids = ["${aws_security_group.final_consul.id}"]

#   tags = {
#     Name = "final-client-${count.index+1}"
#   }
#   user_data = element(data.template_file.consul_client.*.rendered, count.index)
# }


# output "clients" {
#   value = ["${aws_instance.consul_client.*.public_ip}"]
# }
