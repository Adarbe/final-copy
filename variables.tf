############### General ###############

variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "aws_region" {
  default = "us-east-1"
}


############### Networking ###############
variable "pri_subnet" {
  type    = "list"
  default = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}
variable "pub_subnet" {
  type    = "list"
  default = ["10.0.20.0/24", "10.0.30.0/24", "10.0.40.0/24"]
}
variable "network_address_space" {
  default = "10.0.0.0/16"
}
variable "azs" {
  description = "A list of availability zones in the region"
  type        = list
  default     = []
}

variable "servers_keypair_name" {
  description = "Name of the KeyPair used for all nodes"
  default     = "servers_key"
}

############### Jenkins ###############

variable "jenkins_master_port" {
  description = "The Port of the master jenkins instance"
  default     = 8080
}
variable "plugins" {
  type        = list(string)
  description = "A list of Jenkins plugins to install, use short names."
  default     = ["git", "pipeline", "SSH Slaves", "Build Monitor View", "GreenBalls", "Blue Ocean", "Slack Notifications", "GitHub Plugin", "Kubernetes"]
}
variable "jnlp_port" {
  description = "The Port to use for Jenkins master to slave communication bewtween instances"
  default     = 49187
}
variable "jenkins_image_name" {
  description = "Jenkins image name"
  default     = "jenkins"
}
variable "jenkins_image_tag" {
  description = "jenkins image tag"
  default     = "latest"
}

variable "jenkins_servers" {
  description = "The number of consul servers."
  default = 1
}

variable "jenkins_slave_port" {
  description = "Port number for consul jenkins port"
  default = 22
}

############### Monitoring ###############


variable "monitor_instance_type" {
  default = "t3.small"
}
variable "monitor_servers" {
  default = 1
}
variable "owner" {
  default = "Monitoring"
}

variable "default_keypair_name" {
  description = "Name of the KeyPair used for all nodes"
  default     = "servers_key"
}


############### Consul ###############
variable "region" {
  description = "AWS region for VMs"
  default = "us-east-1"
}
variable "path" {
    type = "string"
    default = "/Users/adarb/projects/final-copy/" 
}
variable "consul_servers" {
  description = "The number of consul servers."
  default = 3
}
variable "consul_version" {
  description = "The version of Consul to install (server and client)."
  default     = "1.4.0"
}
variable "key_name" {
  description = "name of ssh key to attach to hosts"
  default = "servers_keypair_name"
}
variable "clients" {
  description = "The number of consul client instances"
  default = 3
}

variable "prometheus_dir" {
  description = "directory for prometheus binaries"
  default = "/opt/prometheus"
}

variable "prometheus_conf_dir" {
  description = "directory for prometheus configuration"
  default = "/etc/prometheus"
}

variable "node_exporter_version" {
  description = "Node Exporter version"
  default = "0.18.1"
}

