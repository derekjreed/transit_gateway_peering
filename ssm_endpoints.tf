resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = aws_vpc.local.id
  service_name = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.allow_web_local.id]
  private_dns_enabled = false
  subnet_ids          = [aws_subnet.local1.id]

  tags = {
    Name = "local-ssm-endpoint"
  }
}
/*
data "aws_vpc_endpoint" "ssm" {
  vpc_id       = aws_vpc.local.id
  service_name = "com.amazonaws.us-east-1.ssm"
}
*/
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id       = aws_vpc.local.id
  service_name = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.allow_web_local.id]
  private_dns_enabled = false
  subnet_ids          = [aws_subnet.local1.id]

  tags = {
    Name = "local-ssmmessages-endpoint"
  }
}
/*
data "aws_vpc_endpoint" "ssmmessages" {
  vpc_id       = aws_vpc.local.id
  service_name = "com.amazonaws.us-east-1.ssmmessages"
}
*/
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id       = aws_vpc.local.id
  service_name = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.allow_web_local.id]
  private_dns_enabled = false
  subnet_ids          = [aws_subnet.local1.id]

  tags = {
    Name = "local-ec2messages-endpoint"
  }
}
/*
data "aws_vpc_endpoint" "ec2messages" {
  vpc_id       = aws_vpc.local.id
  service_name = "com.amazonaws.us-east-1.ec2messages"
}
*/
/*
resource "aws_vpc_endpoint" "ec2" {
  vpc_id       = aws_vpc.local.id
  service_name = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"
    security_group_ids = [aws_security_group.allow_web_local.id]
  private_dns_enabled = false
  subnet_ids          = [aws_subnet.local1.id]

  tags = {
    Name = "local-ec2-endpoint"
  }
}
*/
