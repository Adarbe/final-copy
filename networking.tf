########## Networking ########


resource "aws_internet_gateway" "final_IGW" {
  vpc_id = "${aws_vpc.final-project.id}"
  tags = {
    Name = "final_IGW"
  }
}

######### Subnets ############

resource "aws_subnet" "pubsub" {
  vpc_id                  = "${aws_vpc.final-project.id}"
  count                   = "${length(var.pub_subnet)}"
  cidr_block              = "${element(var.pub_subnet, count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "pubsub ${count.index+1}"
  }
}

#############################
##### Route tables #####

resource "aws_route_table" "pubroute" {
  vpc_id = "${aws_vpc.final-project.id}"
  count = "${length(var.pub_subnet)}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.final_IGW.id}"
  }
}


resource "aws_route_table_association" "pubroute" {
  subnet_id      = "${aws_subnet.pubsub[count.index].id}"
  route_table_id = "${aws_route_table.pubroute[count.index].id}"
  count          = "${length(var.pub_subnet)}"
}




