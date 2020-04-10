###########################

output "Jenkins_Master_Public_IP"  {
  value = "${aws_instance.jenkins_master.public_ip}"
}
output "Jenkins_Master_Private_IP"{
  value = "${aws_instance.jenkins_master.private_ip}"
}


###########################

output "Jenkins_Slave_Public_IP"  {
value = "${aws_instance.jenkins_slave.*.public_ip}"
}
output "Jenkins_Slaves_Private_IP" {
    value = "${aws_instance.jenkins_slave.*.private_ip}"
}

###########################
output "Monitor_Server_Public_IP" {
  value = "${aws_instance.monitor.*.public_ip}"
}

output "consul_servers" {
  value = ["${aws_instance.consul_server.*.public_ip}"]
}


###########################

# output "kibana_url" {
#   value       = "http://${aws_eip.ip.public_ip}:5601"
#   description = "URL to your ELK server's Kibana web page"
# }

