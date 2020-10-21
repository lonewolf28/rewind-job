##########################################
#Create a new VPC for our dev environment#
##########################################



data "aws_availability_zones" "available" {}


resource "aws_vpc" "this" {
  cidr_block = local.cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main_vpc"
    Environment = terraform.workspace
  }
}


resource "aws_subnet" "public" {
  count      = length(local.subnet_public)
  cidr_block = element(local.subnet_public, count.index)
  vpc_id     = aws_vpc.this.id

  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public_subnets"
    Environment = terraform.workspace
  }
}



resource "aws_subnet" "private" {
  count      = length(local.subnet_private)
  cidr_block = element(local.subnet_private, count.index)
  vpc_id     = aws_vpc.this.id
  availability_zone  = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private_subnets"
    Environment = terraform.workspace
  }
}



resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "main_igw"
    Environment = terraform.workspace
  }
}


resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "private_nat_eip"
  }
}


resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     =  aws_subnet.public[0].id

  tags = {
    Name = "main_private_nat_gw"
  }
  depends_on = [
      aws_subnet.public,
  ]
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "main_private_route"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id

  timeouts {
    create = "5m"
  }
}



resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}




resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.this.id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main_public_route"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}






