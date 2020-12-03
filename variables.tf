// AWS Variables
variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_secret_key" {
  type    = string
  default = ""
}

variable "db_table_name" {
  type    = string
  default = "terraform-learn"
}

variable "db_read_capacity" {
  type    = number
  default = 1
}

variable "db_write_capacity" {
  type    = number
  default = 1
}

// PAN-OS Variables

variable "panos_version" {
  type    = string
  default = "9.1.0"
}
