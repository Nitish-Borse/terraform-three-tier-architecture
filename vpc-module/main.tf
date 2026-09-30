# VPC Creation
resource "aws_vpc" "three-tier-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraform-three-tier-vpc"
  }
}

#Internet Gateway Creation
resource "aws_internet_gateway" "three-tier-igw" {
  vpc_id = aws_vpc.three-tier-vpc.id

  tags = {
    Name = "three-tier-igw"
  }
}

#Web Subnet Creation
resource "aws_subnet" "web-subnet" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "three-tier-web-subnet"
  }
}

#App Subnet Creation
resource "aws_subnet" "app-subnet" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "three-tier-app-subnet"
  }
}

#DB Subnet creation
resource "aws_subnet" "db-subnet" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zones[2]

  tags = {
    Name = "three-tier-db-subnet"
  }
}

# Second DB Subnet
resource "aws_subnet" "db-subnet-2" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.availability_zones[3]

  tags = {
    Name = "three-tier-db-subnet-2"
  }
}

#Public Route Table Creation
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three-tier-igw.id
  }

  tags = {
    Name = "three-tier-public-rt"
  }
}

#App Private Route Table Creation
resource "aws_route_table" "app-private-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id
  tags = {
    Name = "three-tier-app-private-rt"
  }
}

# DB Private Route Table
resource "aws_route_table" "db-private-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id

  tags = {
    Name = "three-tier-db-private-rt"
  }
}

#Route Table Association
resource "aws_route_table_association" "web-association" {
  subnet_id      = aws_subnet.web-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "app-association" {
  subnet_id      = aws_subnet.app-subnet.id
  route_table_id = aws_route_table.app-private-rt.id
}

resource "aws_route_table_association" "db-association" {
  subnet_id      = aws_subnet.db-subnet.id
  route_table_id = aws_route_table.db-private-rt.id
}

resource "aws_route_table_association" "db-association-2" {
  subnet_id      = aws_subnet.db-subnet-2.id
  route_table_id = aws_route_table.db-private-rt.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "three-tier-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.web-subnet.id

  depends_on = [
    aws_internet_gateway.three-tier-igw
  ]

  tags = {
    Name = "three-tier-nat-gateway"
  }
}

# Route App subnet internet traffic through NAT Gateway
resource "aws_route" "app_nat_route" {
  route_table_id         = aws_route_table.app-private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}
