# Declares the input variables for the EC2 module.
# These variables allow for customization when the module is used.

variable "instance_type" {
  description = "The type of the EC2 instance (e.g., t2.micro)."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance. Using a recent Amazon Linux 2 AMI for us-east-1."
  type        = string
  default     = "ami-0a3c3a20c09d6f377" # Updated to a more recent Amazon Linux 2 AMI for us-east-1
}

variable "instance_name" {
  description = "The name tag for the EC2 instance."
  type        = string
  default     = "MyPrivateInstance"
}

variable "subnet_cidr_block" {
  description = "The CIDR block for the new private subnet."
  type        = string
  default     = "172.31.99.0/24" # Example CIDR, ensure it doesn't overlap with existing subnets in the default VPC
}

variable "iam_role_name" {
  description = "The name for the IAM role to be created for SSM."
  type        = string
  default     = "EC2-SSM-Role"
}

variable "ebs_volume_size" {
  description = "The size of the EBS volume in gigabytes."
  type        = number
  default     = 8
}

variable "ebs_volume_type" {
  description = "The type of the EBS volume (e.g., gp2, gp3, io1)."
  type        = string
  default     = "gp3"
}

variable "ebs_device_name" {
  description = "The device name to expose to the instance (e.g., /dev/sdh)."
  type        = string
  default     = "/dev/sdh"
}
