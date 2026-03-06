output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kubelet_identity" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "key_vault_secrets_provider_identity_object_id" {
  value = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id
}
