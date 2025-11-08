# allocate elasticIP(eip), it will be used for the nat-gw in public_subnet_az1
resource "aws_eip" "eip_for_nat_gateway_az1" {
    domain = "vpc"

    tags = {
        Name = "nat gateway az1 eip"
    }
}

# allocate elasticIP(eip), to be used for nat-gw in public_subnet_az2
resource "aws_eip" "eip_for_nat_gateway_az2" {
    domain = "vpc"

    tags = {
        Name = "nat gateway az2 eip"
    }
}


# create nat gateway resource in public_subnet_az1
resource "aws_nat_gateway" "nat_gateway_az1" {
    allocation_id = aws_eip.eip_for_nat_gateway_az1.id 
    subnet_id = var.public_subnet_az1_id

    tags = {
        Name = "nat gateway az1"
    }
}

# create nat gw resource in public_subnet_az2
resource "aws_nat_gateway" "nat_gateway_az2" {
    allocation_id = aws_eip.eip_for_nat_gateway_az2.id 
    subnet_id = var.public_subnet_az2_id

    tags = {
        Name = "nat gateway az2"
    }

    # to ensure proper ordering, add an explicit dependency on the igw for vpc
    depends_on = [var.igw]
}


# create private route table az1 and add route through nat gateway az1
resource "aws_route_table" "private_route_table_az1" {
    vpc_id = var.vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway_az1.id  
    }

    tags = {
        Name ="private route table az1"
    }
}

# associate private subnet az1 with private route table az1
resource "aws_route_table_association" "private_subnet_az1_route_table_az1_association" {
    subnet_id = var.private_subnet_az1_id
    route_table_id = aws_route_table.private_route_table_az1.id 
}

# create private route table az2 and add route through nat gateway az2
resource "aws_route_table" "private_route_table_az2" {
    vpc_id = var.vpc_id 

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway_az2.id 
    }
    tags = {
        Name = "private route table az2"
    }
}

# associate private subnet az2 with private route table az2 
resource "aws_route_table_association" "private_subnet_az2_route_table_az2_association" {
    subnet_id = var.private_subnet_az2_id
    route_table_id = aws_route_table.private_route_table_az2.id 
}