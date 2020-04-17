locals {
  jenkins_default_name = "jenkins"
  jenkins_home = "/home/ubuntu/jenkins_home"
  jenkins_home_mount = "${local.jenkins_home}:/var/jenkins_home"
  docker_sock_mount = "/var/run/docker.sock:/var/run/docker.sock"
  java_opts = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"
}





data "template_file" "jenkins_master_sh" {
  template = file("${path.module}/jenkins/templates/master.sh")
}

data "template_file" "consul_jenkins" {
  template = file("${path.module}/consul/templates/consul-agent.sh.tpl")

  vars = {
    consul_version = var.consul_version
    node_exporter_version = var.node_exporter_version
    prometheus_dir = var.prometheus_dir
    config = <<EOF
       "node_name": "jenkins-server-1",
       "enable_script_checks": true
      EOF
  }
}

data "template_file" "consul_jenkins_tpl" {
  template = file("${path.module}/jenkins/templates/jenkins_master.sh.tpl")
}


# Create the user-data for the jenkins master
data "template_cloudinit_config" "consul_jenkins_settings" {
  part {
    content = data.template_file.jenkins_master_sh.rendered
  }
  part {
    content = data.template_file.consul_jenkins.rendered
  }
  part {
    content = data.template_file.consul_jenkins_tpl.rendered
  }

}
resource "aws_instance" "jenkins_master" {
#######################################################
# description = "create EC2 machine for jenkins master"
#######################################################
  ami = "ami-07d0cf3af28718ef8"
  instance_type = "t2.micro"
  key_name = aws_key_pair.servers_key.key_name
  tags = {
    Name = "Jenkins_Master-1"
    Labels = "linux"
  }
  vpc_security_group_ids =["${aws_security_group.default.id}","${aws_security_group.jenkins-final.id}","${aws_security_group.final_consul.id}"]
  subnet_id = "${aws_subnet.pubsub[1].id}"
  connection {
    type = "ssh"
    host = "${aws_instance.jenkins_master.public_ip}"
    private_key = "${tls_private_key.servers_key.private_key_pem}"
    user = "ubuntu"
  }
 
  provisioner "file" {
    source = "Dockerfile"
    destination = "/home/ubuntu/Dockerfile" 
  }
  provisioner "file" {
    source = "plugins.txt"
    destination = "/home/ubuntu/plugins.txt" 
  }
  user_data = data.template_cloudinit_config.consul_jenkins_settings.rendered
}




data "template_file" "consul_jenkins_slave" {
  template = file("${path.module}/consul/templates/consul-agent.sh.tpl")

  vars = {
    consul_version = var.consul_version
    node_exporter_version = var.node_exporter_version
    prometheus_dir = var.prometheus_dir
    config = <<EOF
       "node_name": "jenkins_slave-1",
       "enable_script_checks": true,
      EOF
    }
  }

data "template_file" "consul_jenkins_slave_tpl" {
  template = file("${path.module}/jenkins/templates/jenkins_slave.sh.tpl")
}



#Create the user-data for the jenkins slave
data "template_cloudinit_config" "consul_jenkins_slave_settings" {
  count =  1
  
  part {
    content = element(data.template_file.consul_jenkins_slave.*.rendered, count.index)
  }
  part {
    content = element (data.template_file.consul_jenkins_slave_tpl.*.rendered, count.index)
  }
}
resource "aws_instance" "jenkins_slave" {
#########################################################
# description = "create 3 EC2 machines for jenkins slave"
#########################################################
  count = 1
  #count = "${length(var.pub_subnet)}"
  ami = "ami-07d0cf3af28718ef8"
  instance_type = "t2.micro"
  key_name = "${var.servers_keypair_name}"
  associate_public_ip_address = true
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  subnet_id = "${aws_subnet.pubsub[count.index].id}"
  vpc_security_group_ids =["${aws_security_group.default.id}","${aws_security_group.jenkins-final.id}","${aws_security_group.final_consul.id}",]
  tags = {
    Name = "jenkins_slave-${count.index+1}"
    Labels = "linux"
  }
  connection {
    type = "ssh"
    host = aws_instance.jenkins_slave[count.index].public_ip
    private_key = "${tls_private_key.servers_key.private_key_pem}"
    user = "ubuntu"
  }
  user_data = data.template_cloudinit_config.consul_jenkins_slave_settings[count.index].rendered
}
