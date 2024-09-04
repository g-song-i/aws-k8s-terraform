variable "region" {
  default = "us-west-2"
}

variable "ami_id" {
  default = "ami-0ccca7df258a2259e"
}

variable "master_instance_type" {
  default = "t2.xlarge"
}

variable "worker_instance_type" {
  default = "t2.large"
}

variable "vpc_cidr_block" {
  default = "172.16.0.0/16"
}

variable "subnet_cidr_block" {
  default = "172.16.1.0/24"
}

variable "worker_count" {
  default = 2
}
