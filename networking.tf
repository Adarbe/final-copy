########## Networking ########


resource "aws_internet_gateway" "final_IGW" {
  vpc_id = "${aws_vpc.final-project.id}"
  tags = {
    Name = "final_IGW"
  }
}

# resource "aws_eip" "nateip" {
#   vpc   = true
#   count = 1
# #  count = "${length(var.pri_subnet)}"
# }

# resource "aws_nat_gateway" "final_NATGW" {
#   count = 1
# #  count         = "${length(var.pri_subnet)}"
#   allocation_id = "${element(aws_eip.nateip.*.id, count.index)}"
#   subnet_id     = "${aws_subnet.pubsub[count.index].id}"
#   tags = {
#     Name = "final_NATGW ${count.index+1}"
#   }
# }

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

# resource "aws_subnet" "prisub" {
#   vpc_id                  = "${aws_vpc.final-project.id}"
#   count                   = "${length(var.pri_subnet)}"
#   cidr_block              = "${element(var.pri_subnet, count.index)}"
#   availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "prisub ${count.index+1}"
#   }
# }



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
# resource "aws_route_table" "priroute" {
#   vpc_id = "${aws_vpc.final-project.id}"
#   count  = "${length(var.pri_subnet)}"
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = "${aws_nat_gateway.final_NATGW[count.index].id}"
#  }
#}

resource "aws_route_table_association" "pubroute" {
  subnet_id      = "${aws_subnet.pubsub[count.index].id}"
  route_table_id = "${aws_route_table.pubroute[count.index].id}"
  count          = "${length(var.pub_subnet)}"
}
# resource "aws_route_table_association" "priroute" {
#   count = "${length(var.pri_subnet)}"
#   subnet_id      = "${aws_subnet.prisub[count.index].id}"
#   route_table_id = "${aws_route_table.priroute[count.index].id}"
# }



