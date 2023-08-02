output "name" {
  description = "The name of the kubernetes cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "id" {
  description = "The id of the kubernetes cluster."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "object" {
  description = "The kubernetes cluster object."
  value       = azurerm_kubernetes_cluster.aks
}