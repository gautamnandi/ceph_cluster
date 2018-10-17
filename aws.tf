provider "aws" {
    region = "us-east-2"
    #access_key = "AKIAIUWW4KPROXUIK6KA"
    #secret_key = "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"
}

resource "aws_key_pair" "gnkey" {
    key_name   = "gnkey"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKwuOyAuFoPImu4PNJEE005FO2ssnF+kYb8/3NTppXRDJ8vkggVE1mgG0wOFZfi9afzyTbOvbok+ctQcEqZffqpXHRp01o1ct7NDtYNedHOvPLXdBYZfkxk4n/PDTQB2gNkWJrwic5Q6GAEZkyBSKuhlR1bg2HapydUzDMXOjJET+F0P9oyovM8n/8gdz1gQ7sKR22T+YKS1paUhEpQHbXmXXz3nGxVHop7aDzjG8gN4wQaJmeio2+jGVjfjRlyDiUNwAPE1GBgoVEYLlTEfXoZ1bMGpBic6Xf9del2SOwiF3gm6POvyL/zWxgTVoQYyQL4lmxWFSflT14aDhg8GBf gautamnandi@PC-GN2IN1"
}

# Define our VPC
resource "aws_vpc" "ceph-vpc" {
    cidr_block = "10.99.0.0/16"
    instance_tenancy = "default"

    tags {
        Name = "ceph-vpc"
    }
}

# Define the private subnet
#resource "aws_subnet" "ceph-subnet" {
#    vpc_id = "${aws_vpc.ceph-vpc.id}"
#    cidr_block = "10.99.61.128/25"
#
#    tags {
#        Name = "Ceph Private Subnet"
#    }
#}

# Define the public subnet
resource "aws_subnet" "public-subnet" {
    vpc_id = "${aws_vpc.ceph-vpc.id}"
    #cidr_block = "10.99.1.0/24"
    cidr_block = "10.99.61.128/25"

    tags {
        Name = "Public Subnet"
    }
}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.ceph-vpc.id}"

    tags {
        Name = "VPC IGW"
    }
}

# Define the route table
resource "aws_route_table" "public-rt" {
    vpc_id = "${aws_vpc.ceph-vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }

    tags {
        Name = "Public Subnet RT"
    }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "public-rta" {
    subnet_id = "${aws_subnet.public-subnet.id}"
    route_table_id = "${aws_route_table.public-rt.id}"
}

# Define the security group for the ceph installer node
resource "aws_security_group" "sg-gn" {
    name = "sg_gn"
    description = "Allow incoming HTTP connections & SSH access"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks =  ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.ceph-vpc.id}"

    tags {
        Name = "Public SG"
    }
}

# Define the security group for the ceph nodes
resource "aws_security_group" "sg-ceph"{
    name = "sg_ceph"
    description = "Allow traffic from public subnet"

    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        #cidr_blocks = ["10.99.1.0/24"]
        cidr_blocks = ["10.99.61.128/25"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        #cidr_blocks = ["10.99.1.0/24"]
        cidr_blocks = ["10.99.61.128/25"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.ceph-vpc.id}"

    tags {
        Name = "Ceph SG"
    }
}

# Define the aws_instance for the ceph installer node
resource "aws_instance" "gn_test" {
    ami = "ami-0782e9ee97725263d"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.gnkey.key_name}"
    subnet_id = "${aws_subnet.public-subnet.id}"
    vpc_security_group_ids = ["${aws_security_group.sg-gn.id}"]
    associate_public_ip_address = true
    source_dest_check = false
    user_data = "${file("userdata.sh")}"
    tags {
        Name = "external instance"
    }
}

# Define the aws_instance for the ceph nodes
resource "aws_instance" "ceph_nodes" {
    count = 6
    ami = "ami-0782e9ee97725263d"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.gnkey.key_name}"
    #subnet_id = "${aws_subnet.ceph-subnet.id}"
    subnet_id = "${aws_subnet.public-subnet.id}"
    vpc_security_group_ids = ["${aws_security_group.sg-ceph.id}"]
    associate_public_ip_address = true
    source_dest_check = false
    user_data = "${file("cnodedata.sh")}"
    tags {
        Name = "ceph-node-${count.index + 1}"
    }
}
