# VPC Module: Route Tables

# -----------------------------------------------------------------------------
# Public Route Table
# -----------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rt-pub"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# Private Route Table (App, Data, Cache 공용)
# 단일 NAT Gateway 사용 시 하나의 라우트 테이블 공유
# -----------------------------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rt-priv"
  })
}

resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}

# App Private 서브넷 연결
resource "aws_route_table_association" "app_private" {
  count = length(aws_subnet.app_private)

  subnet_id      = aws_subnet.app_private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Data Private 서브넷 연결
resource "aws_route_table_association" "data_private" {
  count = length(aws_subnet.data_private)

  subnet_id      = aws_subnet.data_private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Cache Private 서브넷 연결
resource "aws_route_table_association" "cache_private" {
  count = length(aws_subnet.cache_private)

  subnet_id      = aws_subnet.cache_private[count.index].id
  route_table_id = aws_route_table.private.id
}

# -----------------------------------------------------------------------------
# PG Dedicated Route Table (PG 전용 NAT Gateway 사용)
# -----------------------------------------------------------------------------
resource "aws_route_table" "pg" {
  count  = var.enable_pg_nat ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rt-pg"
  })
}

resource "aws_route" "pg_nat" {
  count = var.enable_pg_nat ? 1 : 0

  route_table_id         = aws_route_table.pg[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.pg[0].id
}

resource "aws_route_table_association" "pg_private" {
  count = length(aws_subnet.pg_private)

  subnet_id      = aws_subnet.pg_private[count.index].id
  route_table_id = aws_route_table.pg[0].id
}