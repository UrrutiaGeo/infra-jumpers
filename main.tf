data "aws_availability_zones" "available" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region  = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "subnets" {
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  count                   = "${length(data.aws_availability_zones.available.names)}"
  cidr_block              = "10.0.${length(data.aws_availability_zones.available.names) + count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = "${aws_vpc.default.id}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "app" {
  name   = "app_security_group"
  vpc_id = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  # HTTP access from the VPC
  ingress {
    # cidr_blocks = ["10.0.0.0/16"]
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  # Outbound internet access
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

resource "aws_security_group" "rds" {
  name   = "rds_security_group"
  vpc_id = "${aws_vpc.default.id}"

  # Allowing traffic from the web server
  ingress {
    from_port       = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app.id}"]
    to_port         = 3306
  }

  # Outbound internet access
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "app" {
  // Debian Stretch AMI.
  ami           = "ami-003f19e0e687de1cd"
  instance_type = "t2.nano"

  # The name of our SSH keypair we created above.
  key_name  = "${aws_key_pair.auth.id}"
  subnet_id = "${aws_subnet.subnets.0.id}"

  vpc_security_group_ids = ["${aws_security_group.app.id}"]

  connection = {
    # The default username for our AMI
    user = "admin"
  }
}
