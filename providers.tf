terraform {

  required_providers {

    rancher2 = {
      source  = "rancher/rancher2"
      version = "5.0.0"
    }
  } # End of required_providers
}   # End of terraform

provider "vsphere" {
  vsphere_server       = var.vsphere_env.server
  user                 = var.vsphere_env.user
  password             = var.vsphere_env.pass
  allow_unverified_ssl = true
}


provider "rancher2" {
  api_url   = "rancherurl"
  insecure  = true
  token_key = "token"
}
