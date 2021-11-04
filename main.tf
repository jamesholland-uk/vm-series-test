//Providers

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

// AWS

# VPC
resource "aws_vpc" "pavm-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = false
  tags = {
    Name      = var.vpc_name
    yor_trace = "89e57fc9-1a18-45df-bb17-e9c9cfb5fabb"
  }
}

# Management subnet
resource "aws_subnet" "mgmt-subnet" {
  vpc_id                  = aws_vpc.pavm-vpc.id
  cidr_block              = var.mgmt_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name      = "mgmt-subnet"
    yor_trace = "44bc656c-be3d-4092-81ea-760ad25f3e90"
  }
}

# Untrust subnet
resource "aws_subnet" "untrust-subnet" {
  vpc_id                  = aws_vpc.pavm-vpc.id
  cidr_block              = var.untrust_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name      = "untrust-subnet"
    yor_trace = "4947ddb1-b0e9-4e22-b9e3-bbdae4ce4f64"
  }
}

# Trust subnet
resource "aws_subnet" "trust-subnet" {
  vpc_id                  = aws_vpc.pavm-vpc.id
  cidr_block              = var.trust_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name      = "trust-subnet"
    yor_trace = "cf6581a6-a946-4c1f-a7ae-8c8466f9267c"
  }
}

# Internet Gateway (IGW)
resource "aws_internet_gateway" "pavm-igw" {
  vpc_id = aws_vpc.pavm-vpc.id
  tags = {
    Name      = "internet_gateway"
    yor_trace = "806bc479-c974-43fa-8a4e-1e2e9ac115d9"
  }
}

# Management route table
resource "aws_route_table" "mgmt-routetable" {
  vpc_id = aws_vpc.pavm-vpc.id
  tags = {
    Name      = "mgmt-routetable"
    yor_trace = "ce1e71fc-eb3f-4595-a1e2-d5c800a2d0f6"
  }
}

# Default route for Management route table
resource "aws_route" "mgmt-default-route" {
  route_table_id         = aws_route_table.mgmt-routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.pavm-igw.id
  depends_on = [
    aws_route_table.mgmt-routetable,
    aws_internet_gateway.pavm-igw
  ]
}

# Associate Management route table to Management subnet
resource "aws_route_table_association" "mgmt-routetable-association" {
  subnet_id      = aws_subnet.mgmt-subnet.id
  route_table_id = aws_route_table.mgmt-routetable.id
}

# Untrust route table
resource "aws_route_table" "untrust-routetable" {
  vpc_id = aws_vpc.pavm-vpc.id
  tags = {
    Name      = "untrust-routetable"
    yor_trace = "3f8457ea-e4a4-4d5e-bfc9-57d3314f6500"
  }
}

# Default route for Untrust route table
resource "aws_route" "untrust-default-route" {
  route_table_id         = aws_route_table.untrust-routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.pavm-igw.id
  depends_on = [
    aws_route_table.untrust-routetable,
    aws_internet_gateway.pavm-igw
  ]
}

# Associate Untrust route table to Untrust subnet
resource "aws_route_table_association" "untrust-routetable-association" {
  subnet_id      = aws_subnet.untrust-subnet.id
  route_table_id = aws_route_table.untrust-routetable.id
}

# Trust route table
resource "aws_route_table" "trust-routetable" {
  vpc_id = aws_vpc.pavm-vpc.id
  tags = {
    Name      = "trust-routetable"
    yor_trace = "0cff1b82-d507-46fd-a9fb-76fabb62acec"
  }
}

# Associate Trust route table to Trust subnet
resource "aws_route_table_association" "trust-routetable-association" {
  subnet_id      = aws_subnet.trust-subnet.id
  route_table_id = aws_route_table.trust-routetable.id
}

# Default VPC Network ACL
resource "aws_network_acl" "default-network-acl" {
  vpc_id = aws_vpc.pavm-vpc.id
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  subnet_ids = [
    aws_subnet.mgmt-subnet.id,
    aws_subnet.untrust-subnet.id,
    aws_subnet.trust-subnet.id
  ]
  tags = {
    Name      = "Default ACL"
    yor_trace = "e29c3319-74bb-424c-86eb-dd83f55759b5"
  }
}

# Default VPC security group
resource "aws_security_group" "default-security-gp" {
  name        = "pavm-allow-all"
  vpc_id      = aws_vpc.pavm-vpc.id
  description = "Allow all traffic both directions"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name      = "Allow-all-both-ways"
    yor_trace = "134fd396-64d7-41fd-a6c1-ee83c2c1f787"
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
  vpc_id            = aws_vpc.pavm-vpc.id
  cidr_block        = var.nat_igw__subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name      = "nat-subnet"
    yor_trace = "877f6420-b3c0-45bd-85b4-7a3a29b9a93c"
  }
}
resource "aws_route_table" "nat-routetable" {
  vpc_id = aws_vpc.pavm-vpc.id
  tags = {
    Name      = "nat-routetable"
    yor_trace = "77e13c58-dcbf-455a-8f78-c1418ba1710a"
  }
}
resource "aws_route" "nat-route" {
  route_table_id         = aws_route_table.nat-routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.pavm-igw.id
  depends_on = [
    aws_route_table.nat-routetable
  ]
}
resource "aws_route_table_association" "nat-routetable-association" {
  subnet_id      = aws_subnet.nat-subnet.id
  route_table_id = aws_route_table.nat-routetable.id
}
resource "aws_eip" "nat-eip" {
  vpc = true
  tags = {
    Name      = "nat_eip"
    yor_trace = "7bce3798-e1b0-4278-9310-fafe870ec5a4"
  }
}
resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.nat-subnet.id
  tags = {
    Name      = "nat_gateway"
    yor_trace = "4ac14148-be00-4289-a5d8-01683079cf8c"
  }
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
  #bridgecrew:skip=BC_AWS_PUBLIC_12:We are ok with this VM having a public IP address because it is a VM-Series NGFW
  ami = lookup(var.pavm_payg_bun2_ami_id, var.aws_region)
  #ami = lookup(var.pavm_byol_ami_id, var.aws_region)
  availability_zone                    = var.availability_zone
  tenancy                              = "default"
  ebs_optimized                        = false
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = var.pavm_instance_type
  key_name                             = var.pavm_key_name
  monitoring                           = false
  vpc_security_group_ids               = [aws_security_group.default-security-gp.id]
  subnet_id                            = aws_subnet.mgmt-subnet.id
  associate_public_ip_address          = var.pavm_public_ip
  private_ip                           = var.pavm_mgmt_private_ip
  source_dest_check                    = false
  tags = {
    Name      = "PAVM"
    yor_trace = "f8accd61-39f0-4cd1-859a-52688e14dae0"
  }
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "65"
    delete_on_termination = true
    encrypted             = true
  }

  connection {
    user        = "admin"
    private_key = var.pavm_key_path
  }
  # bootstrap
  #user_data = "vmseries-bootstrap-aws-s3bucket=${var.pavm_bootstrap_s3}"
  #iam_instance_profile = "bootstrap_s3_profile"
  metadata_options {
    http_endpoint = "disabled"
  }
}

# Untrust Interface
resource "aws_network_interface" "untrust_eni" {
  subnet_id         = aws_subnet.untrust-subnet.id
  private_ips       = [var.pavm_untrust_private_ip]
  security_groups   = [aws_security_group.default-security-gp.id]
  description       = "PAVM untrust interface"
  source_dest_check = false
  tags = {
    Name      = "PAVM_untrust_eni"
    yor_trace = "d35871f9-9bbb-49c9-9577-71de01d46699"
  }
  attachment {
    instance     = aws_instance.pavm.id
    device_index = 1
  }
}

# EIP for Untrust Interface
resource "aws_eip" "untrust_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.untrust_eni.id
  associate_with_private_ip = var.pavm_untrust_private_ip
  tags = {
    Name      = "untrust_eip"
    yor_trace = "f2432991-9f90-4603-adc9-064f2f44f6c0"
  }
  depends_on = [
    aws_internet_gateway.pavm-igw
  ]
}

# Trust Interface
resource "aws_network_interface" "trust_eni" {
  subnet_id         = aws_subnet.trust-subnet.id
  private_ips       = [var.pavm_trust_private_ip]
  security_groups   = [aws_security_group.default-security-gp.id]
  description       = "PAVM trust interface"
  source_dest_check = false
  tags = {
    Name      = "PAVM_trust_eni"
    yor_trace = "acfff12f-ad8e-4246-92b8-f55eac5ccdf3"
  }
  attachment {
    instance     = aws_instance.pavm.id
    device_index = 2
  }
}
resource "aws_iam_instance_profile" "bootstrap_s3_profile" {
  name = "bootstrap_s3_profile"
  role = aws_iam_role.bootstrap_s3_role.name
  tags = {
    yor_trace = "7be6e29e-bca6-46d8-bb4a-4c800f85f1df"
  }
}

resource "aws_iam_role" "bootstrap_s3_role" {
  name = "bootstrap_s3_role"
  path = "/"
  tags = {
    Name      = "bootstrap_role"
    yor_trace = "d61a874b-ac71-4716-9b6e-c363714d3f0e"
  }
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

