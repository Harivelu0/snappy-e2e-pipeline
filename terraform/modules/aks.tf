# aks.tf

# Create a random string suffix for DNS prefix
resource "random_string" "aks_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create Log Analytics workspace for AKS monitoring
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.cluster-name}-logs"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster-name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${var.cluster-name}-${random_string.aks_suffix.result}"
  kubernetes_version  = var.cluster-version
  
  # Private cluster configuration
  private_cluster_enabled = true
  
  # Default system node pool
  default_node_pool {
    name                = "system"
    vm_size             = "Standard_DS2_v2"  # Equivalent to t3a.medium in AWS
    node_count          = 1
    # Removed enable_auto_scaling due to error
    vnet_subnet_id      = azurerm_subnet.private-subnet[0].id
    zones               = ["1", "2", "3"]
    
    tags = {
      "nodepool-type" = "system"
    }
  }

  # Use Managed Identity for the cluster
  identity {
    type = "SystemAssigned"
  }

  # Network configuration
  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    service_cidr       = "10.0.0.0/16"
    dns_service_ip     = "10.0.0.10"
    # Removed docker_bridge_cidr due to error
  }

  # Azure Monitor addon
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  # Azure Key Vault addon (if needed)
  key_vault_secrets_provider {
    secret_rotation_enabled = true
    secret_rotation_interval = "2m"
  }

  # Azure Policy addon (if needed)
  azure_policy_enabled = true

  tags = {
    Environment = var.env
    Name        = var.cluster-name
  }

  depends_on = [
    azurerm_subnet.private-subnet
  ]
}

# User node pool with regular priority
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D4s_v3"  # Equivalent to c5a.large in AWS
  node_count            = 1
  # Removed enable_auto_scaling due to error
  vnet_subnet_id        = azurerm_subnet.private-subnet[0].id
  zones                 = ["1", "2", "3"]
  mode                  = "User"
  
  node_labels = {
    "nodepool-type" = "user"
  }
  
  tags = {
    Environment = var.env
    NodePoolType = "user"
  }
}

# Spot node pool (low-priority) for cost savings
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D8s_v3"  # Equivalent to c5a.xlarge in AWS
  node_count            = 1
  # Removed enable_auto_scaling due to error
  vnet_subnet_id        = azurerm_subnet.private-subnet[0].id
  zones                 = ["1", "2", "3"]
  priority              = "Spot"
  eviction_policy       = "Delete"
  spot_max_price        = -1  # default to on-demand price
  
  node_labels = {
    "kubernetes.azure.com/scalesetpriority" = "spot"
    "type"     = "spot"
    "lifecycle" = "spot"
  }
  
  tags = {
    Environment = var.env
    NodePoolType = "spot"
  }
}