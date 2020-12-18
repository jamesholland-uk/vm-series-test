//Providers

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

// AWS

# VPC
resource "aws_vpc" "pavm-vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_support = true
    enable_dns_hostnames = false
    tags = {
        Name = var.vpc_name
    }
}

# Management subnet
resource "aws_subnet" "mgmt-subnet" {
    vpc_id = aws_vpc.pavm-vpc.id
    cidr_block = var.mgmt_subnet_cidr_block
    availability_zone = var.availability_zone
    map_public_ip_on_launch = false
    tags = {
        Name = "mgmt-subnet"
    }
}

# Untrust subnet
resource "aws_subnet" "untrust-subnet" {
    vpc_id = aws_vpc.pavm-vpc.id
    cidr_block = var.untrust_subnet_cidr_block
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
    tags = {
        Name = "untrust-subnet"
    }
}

# Trust subnet
resource "aws_subnet" "trust-subnet" {
    vpc_id = aws_vpc.pavm-vpc.id
    cidr_block = var.trust_subnet_cidr_block
    availability_zone = var.availability_zone
    map_public_ip_on_launch = false
    tags = {
        Name = "trust-subnet"
    }
}

# Internet Gateway (IGW)
resource "aws_internet_gateway" "pavm-igw" {
    vpc_id = aws_vpc.pavm-vpc.id
}

# Management route table
resource "aws_route_table" "mgmt-routetable" {
    vpc_id = aws_vpc.pavm-vpc.id
    tags = {
        Name = "mgmt-routetable"
    }
}

# Default route for Management route table
resource "aws_route" "mgmt-default-route" {
    route_table_id = aws_route_table.mgmt-routetable.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pavm-igw.id
    depends_on = [
        aws_route_table.mgmt-routetable,
        aws_internet_gateway.pavm-igw
    ]
}

# Associate Management route table to Management subnet
resource "aws_route_table_association" "mgmt-routetable-association" {
    subnet_id = aws_subnet.mgmt-subnet.id
    route_table_id = aws_route_table.mgmt-routetable.id
}

# Untrust route table
resource "aws_route_table" "untrust-routetable" {
    vpc_id = aws_vpc.pavm-vpc.id
    tags = {
        Name = "untrust-routetable"
    }
}

# Default route for Untrust route table
resource "aws_route" "untrust-default-route" {
    route_table_id = aws_route_table.untrust-routetable.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pavm-igw.id
    depends_on = [
        aws_route_table.untrust-routetable,
        aws_internet_gateway.pavm-igw
    ]
}

# Associate Untrust route table to Untrust subnet
resource "aws_route_table_association" "untrust-routetable-association" {
    subnet_id = aws_subnet.untrust-subnet.id
    route_table_id = aws_route_table.untrust-routetable.id
}

# Trust route table
resource "aws_route_table" "trust-routetable" {
    vpc_id = aws_vpc.pavm-vpc.id
    tags = {
        Name = "trust-routetable"
    }
}

# Associate Trust route table to Trust subnet
resource "aws_route_table_association" "trust-routetable-association" {
    subnet_id = aws_subnet.trust-subnet.id
    route_table_id = aws_route_table.trust-routetable.id
}

# Default VPC Network ACL
resource "aws_network_acl" "default-network-acl" {
    vpc_id = aws_vpc.pavm-vpc.id
    egress {
        protocol = "-1"
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    ingress {
        protocol = "-1"
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    subnet_ids = [
        aws_subnet.mgmt-subnet.id,
        aws_subnet.untrust-subnet.id,
        aws_subnet.trust-subnet.id
    ]
    tags = {
        Name = "Default ACL"
    }
}

# Default VPC security group
resource "aws_security_group" "default-security-gp" {
    name = "pavm-allow-all"
    vpc_id = aws_vpc.pavm-vpc.id
    description = "Allow all traffic both directions"
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "Allow-all-both-ways"
    }
}

# VPC NAT Gateway
/*resource "aws_internet_gateway" "nat-igw" {
    vpc_id = aws_vpc.pavm-vpc.id
    tags = {
        Name = "NAT Internet Gateway"
    }
}*/
resource "aws_subnet" "nat-subnet" {
    vpc_id = aws_vpc.pavm-vpc.id
    cidr_block = var.nat_igw__subnet_cidr_block
    availability_zone = var.availability_zone
    tags = {
        Name = "nat-subnet"
    }
}
resource "aws_route_table" "nat-routetable" {
    vpc_id = aws_vpc.pavm-vpc.id
    tags = {
        Name = "nat-routetable"
    }
}
resource "aws_route" "nat-route" {
    route_table_id = aws_route_table.nat-routetable.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pavm-igw.id
    depends_on = [
        aws_route_table.nat-routetable
    ]
}
resource "aws_route_table_association" "nat-routetable-association" {
    subnet_id = aws_subnet.nat-subnet.id
    route_table_id = aws_route_table.nat-routetable.id
}
resource "aws_eip" "nat-eip" {
    vpc = true
}
resource "aws_nat_gateway" "gw" {
    allocation_id = aws_eip.nat-eip.id
    subnet_id = aws_subnet.nat-subnet.id
    depends_on = [
        aws_internet_gateway.pavm-igw
    ]
}
/*resource "aws_route" "gw-route" {
    route_table_id = aws_route_table.mgmt-routetable.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
}*/


# Palo Alto Networks VM-Series
resource "aws_instance" "pavm" {
    #ami = lookup(var.pavm_byol_ami_id, var.aws_region)
    ami = lookup(var.pavm_payg_bun2_ami_id, var.aws_region)
    availability_zone = var.availability_zone
    tenancy = "default"
    ebs_optimized = false
    disable_api_termination = false
    instance_initiated_shutdown_behavior = "stop"
    instance_type = var.pavm_instance_type
    key_name = var.pavm_key_name
    monitoring = false
    vpc_security_group_ids = [ aws_security_group.default-security-gp.id ]
    subnet_id = aws_subnet.mgmt-subnet.id
    associate_public_ip_address = var.pavm_public_ip
    private_ip = var.pavm_mgmt_private_ip
    source_dest_check = false
    tags = {
        Name = "PAVM"
    }
    root_block_device {
        volume_type = "gp2"
        volume_size = "65"
        delete_on_termination = true
    }

    connection {
        user = "admin"
        private_key = var.pavm_key_path
    }
    # bootstrap
    //user_data = "vmseries-bootstrap-aws-s3bucket=${var.pavm_bootstrap_s3}"
    //iam_instance_profile = "bootstrap_s3_profile"
}

# Untrust Interface
resource "aws_network_interface" "untrust_eni" {
    subnet_id = aws_subnet.untrust-subnet.id
    private_ips = [ var.pavm_untrust_private_ip ]
    security_groups = [ aws_security_group.default-security-gp.id ]
    description = "PAVM untrust interface"
    source_dest_check = false
    tags = {
        Name = "PAVM_untrust_eni"
    }
    attachment {
        instance = aws_instance.pavm.id
        device_index = 1
    }
}

# EIP for Untrust Interface
resource "aws_eip" "untrust_eip" {
    vpc = true
    network_interface = aws_network_interface.untrust_eni.id
    associate_with_private_ip = var.pavm_untrust_private_ip
    depends_on = [
        aws_internet_gateway.pavm-igw
    ]
}

# Trust Interface
resource "aws_network_interface" "trust_eni" {
    subnet_id = aws_subnet.trust-subnet.id
    private_ips = [ var.pavm_trust_private_ip ]
    security_groups = [ aws_security_group.default-security-gp.id ]
    description = "PAVM trust interface"
    source_dest_check = false
    tags = {
        Name = "PAVM_trust_eni"
    }
    attachment {
        instance = aws_instance.pavm.id
        device_index = 2
    }
}
resource "aws_iam_instance_profile" "bootstrap_s3_profile" {
  name = "bootstrap_s3_profile"
  role = aws_iam_role.bootstrap_s3_role.name
}

resource "aws_iam_role" "bootstrap_s3_role" {
  name = "bootstrap_s3_role"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource aws_iam_role_policy "bootstrap_s3_role_policy" {
  name = "test_policy"
  role = aws_iam_role.bootstrap_s3_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.pavm_bootstrap_s3}",
                "arn:aws:s3:::${var.pavm_bootstrap_s3}/*"
            ]
        }
    ]
}
EOF
}

