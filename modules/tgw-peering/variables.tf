
variable "peer_account_id" {
    type     =string
    description = "Distal AWS account id for peering with"
}

variable "region" {
    type = string
    default = "us-east-1"
    description = "Distal AWS account region peering with"
}

variable "peer_transit_gateway_id" {
    type = string
    description = "Distal AWS account transit gateway id peering with"
}

variable "transit_gateway_id" {
    type = string
    description = "Proximal AWS account transit gateway id peering with"
}

variable "destination_cidr_block" {
    type =set(string)
    default = ["10.0.0.0/16, 12.0.0.0/16", "13.0.0.0/16"]
    description = "CIDR blocks for routing to platform/gitlab VPC"
}