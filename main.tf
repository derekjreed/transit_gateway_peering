resource "aws_vpc" "local" {
  cidr_block = "10.0.0.0/16"

    tags = {
    Name = "vpc-local"
  }
}

resource "aws_internet_gateway" "local" {
  vpc_id = aws_vpc.local.id

  tags = {
    Name = "local"
  }
}


resource "aws_subnet" "local1" {
  vpc_id     = aws_vpc.local.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet-local1"
  }
}


resource "aws_subnet" "local2" {
  vpc_id     = aws_vpc.local.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "subnet-local2"
  }
}

/*
resource "aws_route_table" "localr" {
  vpc_id = aws_vpc.local.id

  tags = {
    Name = "local_main"
  }
}
*/

data "aws_route_table" "local_main" {
  vpc_id = aws_vpc.local.id
}


resource "aws_route" "localr" {
  //route_table_id            = aws_route_table.localr.id
  route_table_id            =  data.aws_route_table.local_main.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.local.id
  //depends_on                = [aws_vpc.local]
}

resource "aws_route" "local_tgw" {
  //route_table_id            = aws_route_table.localr.id
  route_table_id            =  data.aws_route_table.local_main.id
  destination_cidr_block    = "11.0.0.0/16"
  transit_gateway_id        = aws_ec2_transit_gateway.local-tgw.id
  //depends_on                = [aws_route_table.localr]
}

data "aws_route_table" "remote_main" {
  vpc_id = aws_vpc.remote.id
}

resource "aws_route" "remote_tgw" {
  route_table_id            =  data.aws_route_table.remote_main.id
  destination_cidr_block    = "10.0.0.0/16"
  transit_gateway_id        = aws_ec2_transit_gateway.remote-tgw.id
  //depends_on                = [aws_vpc.remote]
}


resource "aws_vpc" "remote" {
  cidr_block = "11.0.0.0/16"

      tags = {
    Name = "vpc-remote"
  }
}

resource "aws_subnet" "remote1" {
  vpc_id     = aws_vpc.remote.id
  cidr_block = "11.0.1.0/24"

  tags = {
    Name = "subnet-remote1"
  }
}

resource "aws_subnet" "remote2" {
  vpc_id     = aws_vpc.remote.id
  cidr_block = "11.0.2.0/24"

  tags = {
    Name = "subnet-remote2"
  }
}


//Transit Gateway Bit
resource "aws_ec2_transit_gateway" "local-tgw" {
  description = "local_tgw"
  tags = {
    "Name" = "local-tgw"
  }
}

resource "aws_ec2_transit_gateway" "remote-tgw" {
  description = "remote_tgw"
  tags = {
    "Name" = "remote-tgw"
  }
}

/*
resource "aws_route_table" "remoter" {
  vpc_id = aws_vpc.remote.id

  tags = {
    Name = "remote_main"
  }
}
*/

resource "aws_ec2_transit_gateway_vpc_attachment" "local1" {
  subnet_ids         = [aws_subnet.local1.id]
  transit_gateway_id = aws_ec2_transit_gateway.local-tgw.id
  vpc_id             = aws_vpc.local.id

  tags = {
    Name = "local_tgw_attach"
  }

}

resource "aws_ec2_transit_gateway_vpc_attachment" "remote1" {
  subnet_ids         = [aws_subnet.remote1.id]
  transit_gateway_id = aws_ec2_transit_gateway.remote-tgw.id
  vpc_id             = aws_vpc.remote.id

  tags = {
    Name = "remote_tgw_attach"
  }

}

/*
provider "aws" {
  alias  = "local"
  region = "us-east-1"
}

provider "aws" {
  alias  = "peer"
  region = "us-west-2"
}

data "aws_region" "peer" {
  provider = aws.peer
}



resource "aws_ec2_transit_gateway" "local" {
  provider = aws.local

  tags = {
    Name = "Local TGW"
  }
}

resource "aws_ec2_transit_gateway" "peer" {
  provider = aws.peer

  tags = {
    Name = "Peer TGW"
  }
}

*/
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_ec2_transit_gateway_peering_attachment" "remote_to_local" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = data.aws_region.current.name
  //peer_region             =  "us-east-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.local-tgw.id
  transit_gateway_id      = aws_ec2_transit_gateway.remote-tgw.id

  tags = {
    Name = "TGW Peering Requestor remote"
    Side = "Creator"
  }
}

# Transit Gateway 2's peering request needs to be accepted.
# So, we fetch the Peering Attachment that is created for the Gateway 2.
data "aws_ec2_transit_gateway_peering_attachment" "local_to_remote" {
  depends_on = [aws_ec2_transit_gateway_peering_attachment.remote_to_local]
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.local-tgw.id]
  }
}
/*
// Local accept
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "from_local" {
  //transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.remote_to_local.id
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_peering_attachment.local_to_remote.id
  depends_on = [aws_ec2_transit_gateway.local-tgw.id]

  tags = {
    Name = "TGW Peering Accept local"
    Side = "Acceptor"
  }
}
*/

data "aws_ec2_transit_gateway_route_table" "local" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }

  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.local-tgw.id]
  }
}

resource "aws_ec2_transit_gateway_route" "local" {
  destination_cidr_block         = "11.0.0.0/16"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.local_to_remote.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.local.id
}

data "aws_ec2_transit_gateway_route_table" "remote" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }

  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.remote-tgw.id]
  }
}

resource "aws_ec2_transit_gateway_route" "remote" {
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.remote_to_local.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.remote.id
}
