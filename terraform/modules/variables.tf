# module/variables.tf
variable "cluster-name" {}
variable "vnet-cidr-block" {}
variable "vnet-name" {}
variable "env" {}
variable "azure-region" {}
variable "pub-subnet-count" {}
variable "pub-cidr-block" {
  type = list(string)
}
variable "pub-availability-zone" {
  type = list(string)
}
variable "pub-sub-name" {}
variable "pri-subnet-count" {}
variable "pri-cidr-block" {
  type = list(string)
}
variable "pri-availability-zone" {
  type = list(string)
}
variable "pri-sub-name" {}
variable "public-rt-name" {}
variable "private-rt-name" {}
variable "pip-name" {}
variable "nat-name" {}
variable "aks-sg" {}

# AKS
variable "is-aks-cluster-enabled" {}
variable "cluster-version" {}
variable "private-cluster-enabled" {}
variable "public-network-access-enabled" {}
variable "addons" {
  type = list(object({
    name    = string
    enabled = bool
  }))
}
variable "system_node_pool_vm_size" {}
variable "user_node_pool_vm_sizes" {}
variable "system_node_pool_desired_count" {}
variable "system_node_pool_min_count" {}
variable "system_node_pool_max_count" {}
variable "user_node_pool_desired_count" {}
variable "user_node_pool_min_count" {}
variable "user_node_pool_max_count" {}