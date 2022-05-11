provider "aws" {
    access_key = "xxxxxx"
    secret_key = "xxxxxx"
    region = "us-east-1"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/18"
    
    tags = {
      "Name" = "Main_VPC"
    }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "public subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main_IGW"
  }
}

resource "aws_eip" "nat_eip" {
    vpc = true
    depends_on = [aws_internet_gateway.gw]
    tags = {
        Name = "NAT Gateway EIP"
    }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "Main Nat Gateway"
  }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
       cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.gw.id
    } 
    tags = {
       Name = "Public Route Table"
    }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    route {
       cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.gw.id
    } 
    tags = {
       Name = "Private Route Table"
    }
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}