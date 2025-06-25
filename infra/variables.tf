variable "availability_zone" {
  type = list(string)
  default = [ "ap-south-1a","ap-south-1b"]
}

variable "project_name" {
  type = string
  default = "Mario_Super"
}

variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "private_subnet_cidr_block" {
  type = list(string)
  default = ["10.0.3.0/24","10.0.4.0/24"]
}

variable "instance_type" {
  type = string
  default = "t3.medium"
}

variable "ami_id" {
  type = string
  default = "ami-0b09627181c8d5778"
}


