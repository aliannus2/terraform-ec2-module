# This is the main logic file for the module.
# It defines the resources that Terraform will manage.

# Data source to get information about the default VPC in the selected region.
data "aws_vpc" "default" {
  default = true
}

# Data source to get the list of availability zones in the current region.
data "aws_availability_zones" "available" {
  state = "available"
}

# Resource to create a new private subnet within the default VPC.
# The instance will be launched in this subnet.
resource "aws_subnet" "private_subnet" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = var.subnet_cidr_block
  # Use the first available zone from the aws_availability_zones data source.
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.instance_name}-subnet"
  }
}

# IAM Role for SSM Access
resource "aws_iam_role" "ssm_role" {
  name = var.iam_role_name

  # Policy that allows EC2 to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.instance_name}-ssm-role"
  }
}

# Attaches the AWS managed policy for SSM to the role.
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Creates an instance profile to pass the IAM role to the EC2 instance.
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "${var.iam_role_name}-profile"
  role = aws_iam_role.ssm_role.name
}

# Resource to create the EC2 instance.
resource "aws_instance" "private_ec2" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.private_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  # This instance will not have a public IP address.
  associate_public_ip_address = false

  # User data script to install/start the SSM agent on boot.
  # Amazon Linux 2 has the agent pre-installed, but this ensures it's running.
  user_data = <<-EOF
              #!/bin/bash
              # Installs or updates the SSM agent. On Amazon Linux 2, it's pre-installed.
              yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
              # Ensures the agent is running and enabled on boot
              systemctl start amazon-ssm-agent
              systemctl enable amazon-ssm-agent
              EOF

  tags = {
    Name = var.instance_name
  }

  # Adding a lifecycle rule to ignore changes to the AMI ID after creation.
  lifecycle {
    ignore_changes = [ami]
  }
}

# Resource to create an EBS volume.
resource "aws_ebs_volume" "data_volume" {
  availability_zone = aws_instance.private_ec2.availability_zone
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type

  tags = {
    Name = "${var.instance_name}-data-volume"
  }
}

# Resource to attach the EBS volume to the EC2 instance.
resource "aws_volume_attachment" "ebs_att" {
  device_name = var.ebs_device_name
  volume_id   = aws_ebs_volume.data_volume.id
  instance_id = aws_instance.private_ec2.id
}
