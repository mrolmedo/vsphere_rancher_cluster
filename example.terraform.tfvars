rancher_env = {
  cloud_credential    = "cloud-credential"
  cluster_annotations = { "foo" = "bar" }
  cluster_labels      = { "rke2" = "tf" }
  rke2_version        = "v1.28.13+rke2r1"
}


# These are machine specs for nodes.  Be mindful of System Requirements!
node = {
  ctl_plane = { hdd_capacity = 20000, name = "ctl-plane", quantity = 1, vcpu = 1, vram = 4096 }
  worker    = { hdd_capacity = 20000, name = "worker", quantity = 1, vcpu = 4, vram = 4096 }
}

vsphere_env = {
  cloud_image_name = "your-image-here"
  compute_node     = "esxi.node.local"
  datacenter       = "datacenter"
  datastore        = "fast"
  ds_url           = "ds:///vmfs/volumes/63e28e23-60cb40ae-89b0-ac1f6b7e1b04/"
  library_name     = "rancher-templates"
  server           = "appliance.fqdn or IP"
  user             = "rancher_user@vsphere.local"
  vm_network       = "k8s"
}
