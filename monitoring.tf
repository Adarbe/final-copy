# # Get Ubuntu AMI information 
# data "aws_ami" "ubuntu" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#   owners = ["099720109477"] # Canonical
# }

# data "template_file" "consul_monitoring" {
#   template = file("${path.module}/consul/templates/consul-agent.sh.tpl")
  
#   vars = {
#     consul_version = var.consul_version
#     node_exporter_version = var.node_exporter_version
#     prometheus_dir = var.prometheus_dir
#     config = <<EOF
#        "node_name": "monitoring-server",
#        "enable_script_checks": true,
#       EOF
#   }
# }

# data "template_file" "consul_monitoring_tpl" {
#   template = file("${path.module}/monitoring/monitoring_server.sh.tpl")
# }

# data "template_file" "monitoring_sh" {
#   template = file("${path.module}/monitoring/monitoring_server.sh")
# }

# #Create the user-data for the monitoring server

# data "template_cloudinit_config" "consul_monitoring_settings" {
#   part {
#     content = data.template_file.consul_monitoring.rendered
#   }
#    part {
#     content = data.template_file.consul_monitoring_tpl.rendered
#   }
#    part {
#     content = data.template_file.monitoring_sh.rendered
#   }
# }

# # Allocate the EC2 monitoring instance
# resource "aws_instance" "monitor" {
#   count = "${var.monitor_servers}"
#   ami = data.aws_ami.ubuntu.id
#   instance_type = "${var.monitor_instance_type}"
#   iam_instance_profile = aws_iam_instance_profile.consul-join.name
#   subnet_id = "${aws_subnet.pubsub[2].id}"
#   vpc_security_group_ids = ["${aws_security_group.monitor_sg.id}","${aws_security_group.final_consul.id}"]
#   key_name = aws_key_pair.servers_key.key_name
#   associate_public_ip_address = true
#   tags = {
#     Owner = var.owner
#     Name  = "Monitor-${count.index+1}"
#     Labels = "linux"
#   }
#   connection {
#     type = "ssh"
#     host = "${aws_instance.monitor[count.index].public_ip}"
#     private_key = "${tls_private_key.servers_key.private_key_pem}"
#     user = "ubuntu"
#   }
#   provisioner "file" {
#     source      = "monitoring"
#     destination = "/home/ubuntu/"
#   }
  
  
#   user_data = data.template_cloudinit_config.consul_monitoring_settings.rendered
# }