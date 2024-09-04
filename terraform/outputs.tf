output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.k8s_vpc.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.k8s_igw.id
}

output "route_table_id" {
  description = "The ID of the Route Table"
  value       = aws_route_table.k8s_rt.id
}

output "subnet_id" {
  description = "The ID of the Subnet"
  value       = aws_subnet.k8s_subnet.id
}

output "master_security_group_id" {
  description = "The ID of the Master Security Group"
  value       = aws_security_group.master_sg.id
}

output "worker_security_group_id" {
  description = "The ID of the Worker Security Group"
  value       = aws_security_group.worker_sg.id
}

output "master_instance_ids" {
  description = "The IDs of the Master Instance"
  value       = [aws_instance.master_instance.id]
}

output "worker_instance_ids" {
  description = "The IDs of the Worker Instances"
  value       = aws_instance.worker_instance.*.id
}

output "region" {
  description = "The AWS region the resources are created in"
  value       = var.region
}
