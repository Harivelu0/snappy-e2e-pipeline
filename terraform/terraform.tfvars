env                   = "dev"
azure-region          = "eastus"
vnet-cidr-block       = "10.16.0.0/16"
vnet-name             = "vnet"
pub-subnet-count      = 3
pub-cidr-block        = ["10.16.0.0/20", "10.16.16.0/20", "10.16.32.0/20"]
pub-availability-zone = ["1", "2", "3"]
pub-sub-name          = "subnet-public"
pri-subnet-count      = 3
pri-cidr-block        = ["10.16.128.0/20", "10.16.144.0/20", "10.16.160.0/20"]
pri-availability-zone = ["1", "2", "3"]
pri-sub-name          = "subnet-private"
public-rt-name        = "public-route-table"
private-rt-name       = "private-route-table"
pip-name              = "nat-pip"
nat-name              = "natgw"
aks-sg                = "aks-sg"

# AKS
is-aks-cluster-enabled        = true
cluster-version               = "1.28"
cluster-name                  = "aks-cluster"
private-cluster-enabled       = true
public-network-access-enabled = false
system_node_pool_vm_size      = "Standard_DS2_v2"
user_node_pool_vm_sizes       = ["Standard_D4s_v3", "Standard_D8s_v3", "Standard_D2s_v3", "Standard_D4as_v3", "Standard_D8as_v3"]
system_node_pool_desired_count = "1"
system_node_pool_min_count    = "1"
system_node_pool_max_count    = "5"
user_node_pool_desired_count  = "1"
user_node_pool_min_count      = "1"
user_node_pool_max_count      = "10"
addons = [
  {
    name    = "azure-policy"
    enabled = true
  },
  {
    name    = "azure-keyvault-secrets-provider"
    enabled = true
  },
  {
    name    = "monitoring"
    enabled = true
  },
  {
    name    = "azure-cni"
    enabled = true
  }
]
