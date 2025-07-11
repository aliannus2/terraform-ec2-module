# Declares the output values from the module.
# These outputs can be used by other parts of your Terraform configuration.

output "instance_id" {
  description = "The ID of the created EC2 instance."
  value       = aws_instance.private_ec2.id
}

output "instance_private_ip" {
  description = "The private IP address of the EC2 instance."
  value       = aws_instance.private_ec2.private_ip
}

output "subnet_id" {
  description = "The ID of the private subnet created."
  value       = aws_subnet.private_subnet.id
}
