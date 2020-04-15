# data "template_file" "elk_script" {
#   template = file("${path.module}/elk/templates/elasticsearch.sh")
# }


# data "template_file" "consul_elk" {
#   template = file("${path.module}/consul/templates/consul-agent.sh.tpl")

#   vars = {
#     consul_version = var.consul_version
#     node_exporter_version = var.node_exporter_version
#     prometheus_dir = var.prometheus_dir
#     config = <<EOF
#        "node_name": "elk",
#        "enable_script_checks": true,
#       EOF
#     }
#   }
# data "template_file" "consul_elk_tpl" {
#   template = file("${path.module}/elk/templates/elk.sh.tpl")
# }
# data "template_file" "node_exporter_elk" {
#   template = file("${path.module}/node_exporter/inst_node_exporter.sh")
# }
#   #Create the user-data for the ELK
# data "template_cloudinit_config" "elk_config" {
#   part {
#     content = data.template_file.elk_script.rendered
#   }
#   part {
#     content = data.template_file.consul_elk.rendered
#   }
#   part {
#     content = data.template_file.consul_elk_tpl.rendered
#   }
#   part {
#     content = data.template_file.node_exporter_elk.rendered
#   }
# }



# resource "aws_instance" "elk" {
#   ami = "ami-07d0cf3af28718ef8"
#   instance_type = "t2.micro"
#   key_name = aws_key_pair.servers_key.key_name
#   tags = {
#     Name = "elk-final"
#     Labels = "linux"
#   }
#   vpc_security_group_ids = ["${aws_security_group.allow_elk.id}","${aws_security_group.final_consul.id}"]
#   subnet_id = "${aws_subnet.pubsub[2].id}"
#   connection {
#     type = "ssh"
#     host = "${aws_instance.elk.public_ip}"
#     private_key = "${tls_private_key.servers_key.private_key_pem}"
#     user = "ubuntu"
#   }
#   provisioner "file" {
#     content      = "network.bind_host: 0.0.0.0"
#     destination   = "/tmp/elasticsearch.yml"
#   }
#   provisioner "file" {
#     content       = "server.host: 0.0.0.0"
#     destination   = "/tmp/kibana.yml"
#   }
#   provisioner "file" {
#     content       = "http.host: 0.0.0.0"
#     destination   = "/tmp/logstash.yml"
#   }
#   provisioner "file" {
#     source        = "${path.module}/elk/templates/filebeat.yml"
#     destination   = "/tmp/filebeat.yml"
#   }
#   provisioner "file" {
#     source        = "${path.module}/elk/templates/beats.conf"
#     destination   = "/tmp/beats.conf"
#   }


#   user_data = data.template_cloudinit_config.elk_config.rendered
# }


# # resource "aws_eip" "ip" {
# #   instance = "${aws_instance.elk.id}"
# # }

