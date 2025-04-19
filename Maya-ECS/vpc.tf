resource "aws_vpc" "maya_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "maya-ecs-vpc"
  }
}

resource "aws_subnet" "maya_subnet_1" {
  vpc_id            = aws_vpc.maya_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "maya-subnet-1"
  }

  depends_on = [aws_vpc.maya_vpc]
}

resource "aws_subnet" "maya_subnet_2" {
  vpc_id            = aws_vpc.maya_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "maya-subnet-2"
  }

  depends_on = [aws_vpc.maya_vpc]
}

resource "aws_internet_gateway" "maya_igw" {
  vpc_id = aws_vpc.maya_vpc.id

  tags = {
    Name = "maya-igw"
  }
  depends_on = [aws_vpc.maya_vpc]
}

resource "aws_route_table" "maya_rt" {
  vpc_id = aws_vpc.maya_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.maya_igw.id
  }

  tags = {
    Name = "maya-rt"
  }
  depends_on = [aws_internet_gateway.maya_igw]
}

resource "aws_route_table_association" "rt_assoc_1" {
  subnet_id      = aws_subnet.maya_subnet_1.id
  route_table_id = aws_route_table.maya_rt.id
  depends_on = [aws_subnet.maya_subnet_1]
}

resource "aws_route_table_association" "rt_assoc_2" {
  subnet_id      = aws_subnet.maya_subnet_2.id
  route_table_id = aws_route_table.maya_rt.id
  depends_on = [aws_subnet.maya_subnet_2]
}