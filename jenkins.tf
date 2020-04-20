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
  template = file("${path.module}/consul/templates/consulnew.sh.tpl")

  vars = {
      consul_version = var.consul_version
      node_exporter_version = var.node_exporter_version
      prometheus_dir = var.prometheus_dir
      config = <<EOF
       "node_name": "jenkins-server-1",
       "enable_script_checks": true,
       "server": false
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
  ami = "ami-024582e76075564db"
  instance_type = "t2.micro"
  key_name = aws_key_pair.servers_key.key_name
  iam_instance_profile = aws_iam_instance_profile.consul-join.name
  tags = {
    Name = "Jenkins_Master-1"
    Labels = "linux"
  }
  vpc_security_group_ids =["${aws_security_group.default.id}","${aws_security_group.jenkins-final.id}","${aws_security_group.final_consul.id}","${aws_security_group.monitor_sg.id}"]
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
  provisioner "file" {
  source = "jenkins.yaml"
  destination = "/home/ubuntu/jenkins.yaml" 
}
  user_data = data.template_cloudinit_config.consul_jenkins_settings.rendered
}




data "template_file" "consul_jenkins_slave" {
  template = file("${path.module}/consul/templates/consul-agent-linux.sh.tpl")

  vars = {
    node_exporter_version = var.node_exporter_version
    config = <<EOF
       "node_name": "jenkins_slave-1",
       "enable_script_checks": true,
       "server": false
      EOF
    }
  }

data "template_file" "consul_jenkins_slave_tpl" {
  template = file("${path.module}/jenkins/templates/jenkins_slave.sh.tpl")
}

data "template_file" "jenkins_slave_sh" {
  template = file("${path.module}/jenkins/templates/jenkins_slave.sh")
}

#Create the user-data for the jenkins slave
data "template_cloudinit_config" "consul_jenkins_slave_settings" {
  count =  1
  
  part {
    content = element(data.template_file.jenkins_slave_sh.*.rendered, count.index)
  }
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
  ami = "ami-00068cd7555f543d5"
  instance_type = "t2.micro"
  key_name = "${var.servers_keypair_name}"
  associate_public_ip_address = true
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  subnet_id = "${aws_subnet.pubsub[count.index].id}"
  vpc_security_group_ids =["${aws_security_group.default.id}","${aws_security_group.jenkins-final.id}","${aws_security_group.final_consul.id}","${aws_security_group.monitor_sg.id}"]
  tags = {
    Name = "jenkins_slave-${count.index+1}"
    Labels = "linux"
  }
  connection {
    type = "ssh"
    host = aws_instance.jenkins_slave[count.index].public_ip
    private_key = "${tls_private_key.servers_key.private_key_pem}"
    user = "ec2-user"
  }
  user_data = data.template_cloudinit_config.consul_jenkins_slave_settings[count.index].rendered
}


# resource "aws_iam_user" "jenkinsfinal" {
#   name = "jenkinsfinal"
#   path = "/system/"
#   force_destroy = true

#   tags = {
#     tag-key = "tag-value"
#   }
# }

# resource "aws_iam_access_key" "jenkinsfinal" {
#   user = "${aws_iam_user.jenkinsfinal.name}"
# }

# resource "aws_iam_user_policy" "lb_ro" {
#   name = "test"
#   user = "${aws_iam_user.lb.name}"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "ec2:Describe*"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }