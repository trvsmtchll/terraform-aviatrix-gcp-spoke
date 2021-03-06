# GCP Transit Module
module "gcp-transit" {
  source             = "app.terraform.io/aviatrix-tf-solutions/gcp-transit/aviatrix"
  version            = "0.0.4"
  gcp_sub1_cidr      = var.gcp_sub1_cidr
  gcp_sub2_cidr      = var.gcp_sub2_cidr
  gcp_primary_region = var.gcp_primary_region
  gcp_ha_region      = var.gcp_ha_region
  gcp_account_name   = var.gcp_account_name

}


# Aviatrix GCP Spoke VPC
resource "aviatrix_vpc" "gcp_spoke_vpc" {
  cloud_type           = 4
  account_name         = var.gcp_account_name
  name                 = "avx-spoke-vpc-${var.gcp_spoke_region}"
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
  subnets {
    name   = "avx-spoke-sub-${var.gcp_spoke_region}"
    cidr   = var.gcp_spoke_sub1_cidr
    region = var.gcp_spoke_region
  }
}

/*
# Aviatrix GCP Gateway with Peering HA enabled
resource "aviatrix_spoke_gateway" "gcp_spoke_gw" {
  cloud_type         = 4
  account_name       = var.gcp_account_name
  gw_name            = "avx-${var.gcp_spoke_region}-spoke-gw"
  vpc_id             = aviatrix_vpc.default.name
  vpc_reg            = "${var.gcp_spoke_region}-b"
  gw_size            = var.gcp_gw_size
  subnet             = aviatrix_vpc.gcp_spoke_vpc.subnets[0].cidr
  peering_ha_zone    = "${var.gcp_spoke_region}-c"
  peering_ha_subnet  = aviatrix_vpc.gcp_spoke_vpc.subnets[0].cidr
  peering_ha_gw_size = var.gcp_gw_size
  transit_gw         = aviatrix_transit_gateway.gcp_transit_gw.gw_name 
}
*/

# Aviatrix GCP Spoke Gateway
resource "aviatrix_spoke_gateway" "gcp_spoke_gw" {
  cloud_type         = 4
  account_name       = var.gcp_account_name
  gw_name            = "avx-${var.gcp_spoke_region}-spoke-gw"
  vpc_id             = aviatrix_vpc.gcp_spoke_vpc.name
  vpc_reg            = "${var.gcp_spoke_region}-b"
  gw_size            = var.gcp_gw_size
  subnet             = aviatrix_vpc.gcp_spoke_vpc.subnets[0].cidr
  enable_active_mesh = true
  transit_gw         = module.gcp-transit.transit_gateway 
}