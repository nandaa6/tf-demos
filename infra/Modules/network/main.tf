resource "aws_vpc" "main" {
  cidr_block = "${var.cidr}"
  tags = {
    Name = "${var.name}-vpc"
}
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.azs)
  cidr_block              = cidrsubnet(var.cidr, 4, count.index+5)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = {
    Name = "${var.name}-Publicsubnet-${count.index}"
}
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.azs)
  cidr_block              = cidrsubnet(var.cidr, 4, count.index+10)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = {
    Name = "${var.name}-privatesubnet-${count.index}"
}
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name}-public-routetable"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id   
  route_table_id = aws_route_table.public.id
}
