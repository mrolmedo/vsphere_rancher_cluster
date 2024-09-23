
rancher_env = {
  cluster_annotations = { "foo" = "bar" }
  cluster_labels      = { "rke2" = "tf" }
  rke2_version        = "v1.28.13+rke2r1"
}


# These are machine specs for nodes.  Be mindful of System Requirements!
node = {
  ctl_plane = { hdd_capacity = 20000, name = "ctl-plane", quantity = 1, vcpu = 2, vram = 2048 }
  worker    = { hdd_capacity = 20000, name = "worker", quantity = 1, vcpu = 2, vram = 2048 }
}

vsphere_env = {
  template         = "/datacenter/vmfolder/templatefolder/OS-cloudimg"
  datacenter       = "datacenter"
  datastore        = "rancherdatastore"
  folder           = "molmedo"
  ds_url           = "ds:///vmfs/volumes/63e28e23-60cb40ae-89b0-ac1f6b7e1b04/"
  server           = "appliance.fqdn or IP"
  user             = "rancher_user@vsphere.local"

}
