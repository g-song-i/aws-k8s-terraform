provider "aws" {
  region = var.region
}

resource "aws_vpc" "k8s_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
}

resource "aws_route_table" "k8s_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }
}

resource "aws_route_table_association" "k8s_rta" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_rt.id
}

resource "aws_subnet" "k8s_subnet" {
  vpc_id                 = aws_vpc.k8s_vpc.id
  cidr_block             = var.subnet_cidr_block
  map_public_ip_on_launch = true
}

resource "aws_security_group" "master_sg" {
  name        = "k8s_master_sg"
  description = "Security group for Kubernetes master"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress { # ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress { # api server
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # etcd
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # kube services
    from_port   = 10250
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # calico - BGP
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "worker_sg" {
  name        = "k8s_worker_sg"
  description = "Security group for Kubernetes worker nodes"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress { # ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress { # kubelet
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress { # NodePort
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # calico - BGP
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "master_instance" {
  ami                   = var.ami_id
  instance_type         = var.master_instance_type
  subnet_id             = aws_subnet.k8s_subnet.id
  vpc_security_group_ids = [aws_security_group.master_sg.id]
  disable_api_termination = true

  tags = {
    Name = "Kubernetes Master Node"
  }
}

resource "aws_instance" "worker_instance" {
  count                 = var.worker_count
  ami                   = var.ami_id
  instance_type         = var.worker_instance_type
  subnet_id             = aws_subnet.k8s_subnet.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
  disable_api_termination = true

  tags = {
    Name = "Kubernetes Worker Node ${count.index + 1}"
  }
}