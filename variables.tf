variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "panos_version" {
  type    = string
  default = "9.1.0"
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
