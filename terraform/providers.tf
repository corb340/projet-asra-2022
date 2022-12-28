terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.42.0"
    }
  }
}

provider "openstack" {
  auth_url      = "https://auth.cloud.ovh.net/v3/"
  domain_name   = "default"
  alias         = "ovh"
}
