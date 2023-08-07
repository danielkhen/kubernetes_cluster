variable "name" {
  description = "(Required) The name of the kubernetes cluster."
  type        = string
}

variable "location" {
  description = "(Required) The location of the kubernetes cluster."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The resource group name of the kubernetes cluster."
  type        = string
}

variable "default_node_pool" {
  description = "(Required) The default node pool of the kubernetes cluster."
  type = object({
    name                  = string
    node_count            = number
    vm_size               = string
    vnet_subnet_id        = optional(string)
    enable_auto_scaling   = optional(bool)
    enable_node_public_ip = optional(bool)
    max_pods              = optional(number)
    min_count             = optional(number)
    max_count             = optional(number)
    os_sku                = optional(string)
    os_type               = optional(string)
  })
}

variable "node_pools" {
  description = "(Optional) A list of node pools."
  type = list(object({
    name                  = string
    node_count            = number
    vm_size               = string
    vnet_subnet_id        = optional(string)
    enable_auto_scaling   = optional(bool)
    enable_node_public_ip = optional(bool)
    max_pods              = optional(number)
    min_count             = optional(number)
    max_count             = optional(number)
    os_sku                = optional(string)
    os_type               = optional(string)
  }))
  default = []
}

variable "container_registry_id" {
  description = "(Required) The id of the azure container registry to assign access to the."
  type        = string
}

variable "log_analytics_id" {
  description = "(Required) The id of the log analytics workspace."
  type        = string
}

variable "network_plugin" {
  description = "(Optional) The network plugin of the aks, azure, kubenet or none."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["azure", "kubenet", "none"], var.network_plugin)
    error_message = "Network plugin possible values are azure, kubenet and none."
  }
}

variable "private_cluster_enabled" {
  description = "(Optional) Should the kubernetes api get a private ip address on the virtual network."
  type        = bool
  default     = true
}

variable "node_resource_group" {
  description = "(Optional) The resource group name where all the components of the kubernetes cluster reside."
  type        = string
  default     = null
}

variable "dns_prefix" {
  description = "(Optional) The dns prefix for the kuberenetes api."
  type        = string
  default     = null
}

variable "service_cidr" {
  description = "(Optional) The range of ip addresses assigned to services."
  type        = string
  default     = null
}

variable "dns_service_ip" {
  description = "(Optional) The ip address of the dns service."
  type        = string
  default     = null
}

variable "max_node_provisioning_time" {
  description = "(Optional) The maximum time the autoscaler waits for a node to be provisioned."
  type        = string
  default     = "15m"
}