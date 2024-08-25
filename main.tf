
## VPC 
resource "aws_vpc" "vishnu-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vishnu-vpc"
  }
}
 

## Subnet Public 
resource "aws_subnet" "public1-subnet-vishnu" {
  vpc_id     = aws_vpc.vishnu-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-vishnu"
  }
}

resource "aws_subnet" "public2-subnet-vishnu" {
  vpc_id     = aws_vpc.vishnu-vpc.id
  cidr_block = "10.0.11.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-vishnu"
  }
}

## Subnet Private
resource "aws_subnet" "private1-subnet-vishnu" {
  vpc_id     = aws_vpc.vishnu-vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "private-subnet-vishnu"
  }
}

resource "aws_subnet" "private2-subnet-vishnu" {
  vpc_id     = aws_vpc.vishnu-vpc.id
  cidr_block = "10.0.22.0/24"

  tags = {
    Name = "private-subnet-vishnu"
  }
}


## Internet Gateway
resource "aws_internet_gateway" "igw-vishnu" {
  vpc_id = aws_vpc.vishnu-vpc.id

  tags = {
    Name = "igw-vishnu"
  }
}


## Elastic IP

resource "aws_eip" "eip-vishnu" {
  vpc  = true
  tags = {
      Name = "eip-vishnu"
     
  }

}


## NAT Gateway
resource "aws_nat_gateway" "nat-gw-vishnu" {
  allocation_id = aws_eip.eip-vishnu.id
  subnet_id     = aws_subnet.public1-subnet-vishnu.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw-vishnu]
}





## Route table Public 
resource "aws_route_table" "route_table_vishnu_public" {
  vpc_id = aws_vpc.vishnu-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vishnu.id
  }

  tags = {
    Name = "route_table_vishnu_public"
  }
}


## Route table Private 
resource "aws_route_table" "route_table_vishnu_private" {
  vpc_id = aws_vpc.vishnu-vpc.id

 route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw-vishnu.id
  }

  tags = {
    Name = "route_table_vishnu_private"
  }
}



## Route table Association  Public


resource "aws_route_table_association" "rt-table-association_public1_vishnu" {
  subnet_id      = aws_subnet.public1-subnet-vishnu.id
  route_table_id = aws_route_table.route_table_vishnu_public.id
}

resource "aws_route_table_association" "rt-table-association_public2_vishnu" {
  subnet_id      = aws_subnet.public2-subnet-vishnu.id
  route_table_id = aws_route_table.route_table_vishnu_public.id
}


## Route table Association  Private


resource "aws_route_table_association" "rt-table-association_private1_vishnu" {
  subnet_id      = aws_subnet.private1-subnet-vishnu.id
  route_table_id = aws_route_table.route_table_vishnu_private.id
}


resource "aws_route_table_association" "rt-table-association_private2_vishnu" {
  subnet_id      = aws_subnet.private2-subnet-vishnu.id
  route_table_id = aws_route_table.route_table_vishnu_private.id
}


## Security Groups


resource "aws_security_group" "vishnu-sg" {
	
  name        = "vishnu-sg"
  vpc_id      = aws_vpc.vishnu-vpc.id

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
      Name = "vishnu-sg"
  }

}


resource "aws_instance" "ec2-vishnu-public" {
 ami = "ami-0440fa9465661a496"
 vpc_security_group_ids = [ aws_security_group.vishnu-sg.id ]
 subnet_id = aws_subnet.public1-subnet-vishnu.id
 instance_type = "t3.micro"
 key_name = "vishnuptv92-aws-key"
 tags = {
    Name = "ec2-vishnu-public"
  }
}



resource "aws_instance" "ec2-vishnu-private" {
 ami = "ami-0440fa9465661a496"
 vpc_security_group_ids = [ aws_security_group.vishnu-sg.id ]
 subnet_id = aws_subnet.private1-subnet-vishnu.id
 instance_type = "t3.micro"
 key_name = "vishnuptv92-aws-key"
 tags = {
    Name = "ec2-vishnu-private"
  }
}



