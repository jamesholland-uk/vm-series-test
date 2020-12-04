// AWS Base Variables
variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "availability_zone" {
    default = "eu-west-2c"
}

variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_secret_key" {
  type    = string
  default = ""
}

// AWS VPC Variables

variable "vpc_cidr_block" {
  type    = string
  default = "10.50.0.0/16"
}

variable "vpc_name" {
    default = "Main VPC"
}

variable "mgmt_subnet_cidr_block" {
    default = "10.50.0.0/24"
}

variable "untrust_subnet_cidr_block" {
    default = "10.50.1.0/24"
}

variable "trust_subnet_cidr_block" {
    default = "10.50.2.0/24"
}

variable "nat_igw__subnet_cidr_block" {
    default = "10.50.5.0/24"
}


// PAN-OS Variables

/*
variable "panos_version" {
  type    = string
  default = "9.1.0"
}
*/

variable "pavm_payg_bun2_ami_id" {
//    type = map
    default = {
        eu-west-1 = "ami-5d92132e",
        ap-southeast-1 = "ami-946da7f7",
        ap-southeast-2 = "ami-d7c6e5b4",
        ap-northeast-2 = "ami-fb08c195",
        eu-central-1 = "ami-8be001e4",
        ap-northeast-1 = "ami-b84b5ad6",
        us-east-1 = "ami-29a8a243",
        us-west-1 = "ami-12d0ad72",
        sa-east-1 = "ami-19810e75",
        us-west-2 = "ami-e4be4b84",
        us-east-2 = "ami-9ef3c5fb",
        eu-west-2 = "ami-0a54e9baadee7dab6"
    }
}

variable "pavm_byol_ami_id" {
//    type = map
    default = {
        ap-south-1 = "ami-5c187233",
        eu-west-1 = "ami-73971600",
        ap-southeast-1 = "ami-0c60aa6f",
        ap-southeast-2 = "ami-f9c4e79a",
        ap-northeast-2 = "ami-fa08c194",
        eu-central-1 = "ami-74e5041b",
        ap-northeast-1 = "ami-e44b5a8a",
        us-east-1 = "ami-1daaa077",
        us-west-1 = "ami-acd7aacc",
        sa-east-1 = "ami-1d860971",
        us-west-2 = "ami-e7be4b87",
        us-east-2 = "ami-11e1d774"
    }

}

variable "pavm_instance_type" {
    default = "c4.xlarge"
}

variable "pavm_key_name" {
    description = "Name of the SSH keypair to use in AWS"
    default = "jamoi-macbook-ssh"
}

variable "pavm_key_path" {
    description = "Path to the private portion of the SSH key specified."
    default = "jamoi-macbook-ssh.pem"
}

variable "pavm_public_ip" {
    default = "true"
}

variable "pavm_mgmt_private_ip" {
    default = "10.50.0.5"
}

variable "pavm_untrust_private_ip" {
    default = "10.50.1.5"
}

variable "pavm_trust_private_ip" {
    default = "10.50.2.5"
}

variable pavm_bootstrap_s3 {
    default = "pavm-bootstrap-bucket"
}