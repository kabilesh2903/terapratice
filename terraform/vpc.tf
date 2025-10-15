resource "aws_security_group" "kubesg" {
  name        = var.clustersg
  description = "This is to allow server to outside"
  vpc_id = aws_vpc.kubevpc.id
  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    protocol    = "TCP"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_vpc" "kubevpc" {
  cidr_block = var.block1
  tags = {
    Name = var.vpcname
  }
}
resource "aws_subnet" "pubsub01" {
  cidr_block              = var.block2
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.kubevpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = var.pubsub01
  }
}

resource "aws_subnet" "pubsub02" {
  cidr_block              = var.block3
  availability_zone       = "us-east-1b"
  vpc_id                  = aws_vpc.kubevpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = var.pubsub02
  }
}

resource "aws_internet_gateway" "intgate" {
  vpc_id = aws_vpc.kubevpc.id
}
resource "aws_route_table" "pubrt" {
  vpc_id         = aws_vpc.kubevpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.intgate.id
  }
}
resource "aws_route_table_association" "routeassoc1" {
  route_table_id = aws_route_table.pubrt.id
  subnet_id = aws_subnet.pubsub01.id
}
resource "aws_route_table_association" "routeassoc2" {
  route_table_id = aws_route_table.pubrt.id
  subnet_id = aws_subnet.pubsub02.id
}
