resource "aws_default_vpc" "default_vpc" {
}

#terraform import aws_internet_gateway.default_vpc_igw igw-36ee5f5d
resource "aws_internet_gateway" "default_vpc_igw" {
  vpc_id = aws_default_vpc.default_vpc.id
}

resource "aws_default_subnet" "default_subnets" {
  availability_zone = element(["eu-central-1a", "eu-central-1b", "eu-central-1c"], count.index)
  count             = 3
  tags = {
    "Name" = "Public subnet ${count.index}"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_default_vpc.default_vpc.id
  cidr_block        = element(["172.31.48.0/20", "172.31.64.0/20", "172.31.80.0/20"], count.index)
  availability_zone = element(["eu-central-1a", "eu-central-1b", "eu-central-1c"], count.index)
  count             = 3
  tags = {
    "Name" = "Private subnet ${count.index}"
  }
}

resource "aws_nat_gateway" "main_nats" {
  count         = length(aws_subnet.private_subnets)
  allocation_id = element(aws_eip.nat_ips.*.id, count.index)
  subnet_id     = element(aws_default_subnet.default_subnets.*.id, count.index)
  depends_on    = [aws_internet_gateway.default_vpc_igw]
}
 
resource "aws_eip" "nat_ips" {
  count = length(aws_subnet.private_subnets)
  vpc = true
}

resource "aws_route_table" "private_subnets_route_table" {
  count  = length(aws_subnet.private_subnets)
  vpc_id = aws_default_vpc.default_vpc.id
}

resource "aws_route" "private_subnets_routes" {
  count                  = length(aws_subnet.private_subnets)
  route_table_id         = element(aws_route_table.private_subnets_route_table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main_nats.*.id, count.index)
}
 
resource "aws_route_table_association" "private_subnet_route_table_assc" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private_subnets_route_table.*.id, count.index)
}