# VPC Module: NAT Gateway
# VPC당 1개 Regional NAT Gateway (EIP 수동 지정)

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip"
  })

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway (단일, 첫 번째 Public 서브넷에 배치)
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-${local.az_suffixes[0]}"
  })

  depends_on = [aws_internet_gateway.main]
}

# -----------------------------------------------------------------------------
# PG Dedicated NAT Gateway (결제 전용 고정 EIP)
# -----------------------------------------------------------------------------
resource "aws_eip" "pg_nat" {
  count  = var.enable_pg_nat ? 1 : 0
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name_prefix}-pg-nat-eip" })
}

resource "aws_nat_gateway" "pg" {
  count         = var.enable_pg_nat ? 1 : 0
  allocation_id = aws_eip.pg_nat[0].id
  subnet_id     = aws_subnet.public[0].id # Public 서브넷에 배치

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-pg-nat"
  })

  depends_on = [aws_internet_gateway.main]
}