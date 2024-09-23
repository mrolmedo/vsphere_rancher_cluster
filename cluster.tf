

resource "rancher2_machine_config_v2" "nodes" {
  for_each      = var.node
  generate_name = replace(each.value.name, "_", "-")

  vsphere_config {
    cfgparam   = ["disk.enableUUID=TRUE"] # Disk UUID is Required for vSphere Storage Provider
    clone_from = var.vsphere_env.cloud_image_name
    content_library = var.vsphere_env.library_name
    cpu_count       = each.value.cpu_count
    creation_type   = "template"
    folder          = var.vsphere_env.folder
    datacenter      = var.vsphere_env.datacenter
    datastore       = var.vsphere_env.datastore
    disk_size       = each.value.hdd_capacity
    memory_size     = each.value.vram
    network         = var.vsphere_env.vm_network
    vcenter         = var.vsphere_env.server
  }
} # End of rancher2_machine_config_v2

resource "rancher2_cluster_v2" "rke2" {
  annotations        = var.rancher_env.cluster_annotations
  kubernetes_version = var.rancher_env.rke2_version
  labels             = var.rancher_env.cluster_labels
  name               = var.rancher_env.cluster_name

  rke_config {
    chart_values = <<EOF
      rancher-vsphere-cpi:
        vCenter:
          host: ${var.vsphere_env.server}
          port: 443
          insecureFlag: true
          datacenters: ${var.vsphere_env.datacenter}
          username: ${var.vsphere_env.user}
          password: ${var.vsphere_env.pass}

      rancher-vsphere-csi:
        vCenter:
          host: ${var.vsphere_env.server}
          port: 443
          insecureFlag: "1"
          datacenters: ${var.vsphere_env.datacenter}
          username: ${var.vsphere_env.user}
          password: ${var.vsphere_env.pass}  
        storageClass:
          allowVolumeExpansion: true
          datastoreURL: ${var.vsphere_env.ds_url}

      rke2-calico:
        felixConfiguration:
          wireguardEnabled: true
          
  
    EOF

    machine_global_config = <<EOF
      cni: calico
      disable-kube-proxy: false
      etcd-expose-metrics: false

    dynamic "machine_pools" {
      for_each = var.node
      content {
        cloud_credential_secret_name = data.rancher2_cloud_credential.cloud_credential.id
        control_plane_role           = machine_pools.key == "ctl_plane" ? true : false
        etcd_role                    = machine_pools.key == "ctl_plane" ? true : false
        name                         = machine_pools.value.name
        quantity                     = machine_pools.value.quantity
        worker_role                  = machine_pools.key != "ctl_plane" ? true : false

        machine_config {
          kind = rancher2_machine_config_v2.nodes[machine_pools.key].kind
          name = replace(rancher2_machine_config_v2.nodes[machine_pools.key].name, "_", "-")
        }
      } # End of dynamic for_each content
    }   # End of machine_pools
    
    machine_selector_config {
      config = {
        cloud-provider-name     = "rancher-vsphere"
        protect-kernel-defaults: false
      }
    } # End machine_selector_config
  }   # End of rke_config
}     # End of rancher2_cluster_v2
data "rancher2_cloud_credential" "cloud_credential" {
  name = var.vsphere_env.rancher2_cloud_credential_name
}
