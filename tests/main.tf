locals {
  location            = "westeurope"
  resource_group_name = "dtf-kubernetes-cluster-test"
}

resource "azurerm_resource_group" "test_rg" {
  name     = local.resource_group_name
  location = local.location

  lifecycle {
    ignore_changes = [tags["CreationDateTime"], tags["Environment"]]
  }
}

locals {
  acr_name           = "hafifot877"
  acr_resource_group = "storm-hafifot"
}

data "azurerm_container_registry" "hafifot" {
  name                = local.acr_name
  resource_group_name = local.acr_resource_group
}

locals {
  activity_log_analytics_name           = "activity-monitor-log-workspace"
  activity_log_analytics_resource_group = "dor-hub-n-spoke"
}

data "azurerm_log_analytics_workspace" "activity" {
  name                = local.activity_log_analytics_name
  resource_group_name = local.activity_log_analytics_resource_group
}

locals {
  aks_name           = "aks"
  aks_network_plugin = "kubenet"
  aks_service_cidr   = "172.0.0.0/16"
  aks_dns_service_ip = "172.0.0.10"

  default_node_pool = {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
    default    = true
  }

  node_pools = [
    {
      name       = "test"
      node_count = 3
      vm_size    = "Standard_B2s"
      default    = true
    }
  ]
}

module "aks" {
  source = "../"

  name                  = local.aks_name
  location              = local.location
  resource_group_name   = azurerm_resource_group.test_rg.name
  network_plugin        = local.aks_network_plugin
  service_cidr          = local.aks_service_cidr
  dns_service_ip        = local.aks_dns_service_ip
  default_node_pool     = local.default_node_pool
  node_pools            = local.node_pools
  log_analytics_id      = data.azurerm_log_analytics_workspace.activity.id
  container_registry_id = data.azurerm_container_registry.hafifot.id
}