variable "ec2_transit_gateway_peer_owner_id" {
    type  = string
    default = ""
    description = "Remote TGW AWS Account id"
}

variable "region_peer_name" {
    type  = string
    default = "us-east-1"
    description = "Remote TGW region"
}

variable "ec2_transit_gateway_local_id" {
    type = string
    default = ""
    description = "Local twg id"
}

variable "tgw_peering_attachment_local_id" {
    type = string
    default = ""
    description = "Peering attchment ID for customer side"
}