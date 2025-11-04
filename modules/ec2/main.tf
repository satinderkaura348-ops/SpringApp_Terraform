# security groups for vpc endpoints
resource "aws_security_group" "vpc_endpoint_security_group" {
    name = "vpc-endpoint-sg"
    vpc_id = var.vpc_id 
    description = "security group for vpc endpoints"

    # allow inbound HTTPS traffic
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
        description = "allow https traffic from vpc"
    }

    tags = {
        Name = "vpc endpoint security group"
    }
}

locals {
    endpoints = {
        "endpoint-ssm" = {
            name = "ssm"
        },
        "endpoint-ssm-messages" = {
            name = "ssmmessages"
        },
        "endpoint-ec2-messages" = {
            name = "ec2messages"
        }
    }
}

# vpc endpoints
resource "aws_vpc_endpoint" "endpoints" {
    vpc_id = var.vpc_id 
    for_each = local.endpoints 
    vpc_endpoint_type = "Interface"
    service_name = "amazonaws.com.${var.region}.${each.value.name}"
    # add a security group to the vpc endpoint
    vpc_security_group_ids = [aws_security_group.vpc_endpoint_security_group.id]
}

# create iam role for ec2 instance
resource "aws_iam_role" "ec2_role" {
    name = "EC2_SSM_Role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
}

# attach AmazonSSMManagedInstanceCore Policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_role_policy" {
    policy_arn = "arn:aws:iam:aws:policy/AmazonSSMManagedInstanceCore"
    role = aws_iam_role.ec2_role.name
}

# create an instance profile for the ec2 instance and associate the IAM role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "EC2_SSM_Instance_Profile"
    role = aws_iam_role.ec2_role.name
}