resource "rancher2_machine_config_v2" "nodes" {
  for_each      = var.node
  generate_name = replace(each.value.name, "_", "-")

  vsphere_config {
    cfgparam   = ["disk.enableUUID=TRUE"] # Disk UUID is Required for vSphere Storage Provider
    clone_from      = var.vsphere_env.template
    cpu_count       = each.value.vcpu
    creation_type   = "template"
    folder          = var.vsphere_env.folder
    datacenter      = var.vsphere_env.datacenter
    datastore       = var.vsphere_env.datastore
    disk_size       = each.value.hdd_capacity
    memory_size     = each.value.vram
    vcenter         = var.vsphere_env.server
  }
} # End of rancher2_machine_config_v2

resource "rancher2_cluster_v2" "rke2" {
  annotations        = var.rancher_env.cluster_annotations
  kubernetes_version = var.rancher_env.rke2_version
  labels             = var.rancher_env.cluster_labels
  name               = "molmedotf"

  rke_config {
    chart_values = <<EOF
      rke2-calico: {}
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
    EOF

    machine_global_config = <<EOF
      cni: calico
      disable-kube-proxy: false
      etcd-expose-metrics: false
    EOF

    dynamic "machine_pools" {
      for_each = var.node
      content {
        cloud_credential_secret_name = data.rancher2_cloud_credential.auth.id
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
     config = jsonencode({
        cloud-provider-name = "rancher-vsphere"
      })
    } # End machine_selector_config
  }   # End of rke_config
}     # End of rancher2_cluster_v2
