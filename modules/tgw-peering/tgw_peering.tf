resource "aws_ec2_transit_gateway_peering_attachment" "remote_to_local" {
  peer_account_id         = var.peer_account_id
  peer_region             = var.region
  //peer_region             =  "us-east-1"
  peer_transit_gateway_id = var.peer_transit_gateway_id
  transit_gateway_id      = var.transit_gateway_id

  tags = {
    Name = "TGW Peering Requestor remote"
    Side = "Creator"
  }
}

data "aws_ec2_transit_gateway_route_table" "remote" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }

  filter {
    name   = "transit-gateway-id"
    values = [var.transit_gateway_id]
  }
}

resource "aws_ec2_transit_gateway_route" "remote" {
  for_each = var.destination_cidr_block
  destination_cidr_block         = each.key #note: each.key and each.value are the same for a set
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.remote_to_local.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.remote.id
  depends_on = [ aws_ec2_transit_gateway_peering_attachment.remote_to_local ]
}