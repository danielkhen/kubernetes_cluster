locals {
  identity_type = "UserAssigned"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  node_resource_group        = var.node_resource_group
  private_cluster_enabled    = var.private_cluster_enabled
  private_dns_zone_id        = var.private_dns_zone_id
  dns_prefix_private_cluster = var.name

  auto_scaler_profile {
    max_node_provisioning_time = var.max_node_provisioning_time
  }

  network_profile {
    network_plugin = var.network_plugin
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  default_node_pool {
    name                  = var.default_node_pool.name
    node_count            = var.default_node_pool.node_count
    vm_size               = var.default_node_pool.vm_size
    enable_auto_scaling   = var.default_node_pool.enable_auto_scaling
    vnet_subnet_id        = var.default_node_pool.vnet_subnet_id
    enable_node_public_ip = var.default_node_pool.enable_node_public_ip
    max_pods              = var.default_node_pool.max_pods
    max_count             = var.default_node_pool.max_count
    min_count             = var.default_node_pool.min_count
    os_sku                = var.default_node_pool.os_sku
  }

  dynamic "identity" {
    for_each = var.identity_type == "None" ? [] : [true]

    content {
      type         = var.identity_type
      identity_ids = var.user_assigned_identities
    }
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_id
  }

  lifecycle {
    ignore_changes = [tags["CreationDateTime"], tags["Environment"]]
  }
}

locals {
  node_pools_map = { for node_pool in var.node_pools : node_pool.name => node_pool }
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  for_each = local.node_pools_map

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  node_count            = each.value.node_count
  vm_size               = each.value.vm_size
  enable_auto_scaling   = each.value.enable_auto_scaling
  vnet_subnet_id        = each.value.vnet_subnet_id
  enable_node_public_ip = each.value.enable_node_public_ip
  max_pods              = each.value.max_pods
  max_count             = each.value.max_count
  min_count             = each.value.min_count
  os_sku                = each.value.os_sku
  os_type               = each.value.os_type
}

locals {
  role_assignements_map = { for role in var.role_assignments : role.name => role }
}

resource "azurerm_role_assignment" "aks_roles" {
  for_each = local.role_assignements_map

  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = each.value.role
  scope                = each.value.scope
}

locals {
  aks_diagnostic_name = "${azurerm_kubernetes_cluster.aks.name}-diagnostic"
}

module "aks_diagnostic" {
  source = "github.com/danielkhen/diagnostic_setting_module"

  name                       = local.aks_diagnostic_name
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = var.log_analytics_id
}