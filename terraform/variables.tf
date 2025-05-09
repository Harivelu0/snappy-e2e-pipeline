variable "azure-region" {
  description = "The Azure region to deploy resources in"
  default     = "eastus"
}

variable "env" {
  description = "Environment name"
}

variable "cluster-name" {
  description = "Name of the AKS cluster"
}

variable "vnet-cidr-block" {
  description = "CIDR block for the Virtual Network"
}

variable "vnet-name" {
  description = "Name of the Virtual Network"
}

variable "pub-subnet-count" {
  description = "Number of public subnets"
}

variable "pub-cidr-block" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "pub-availability-zone" {
  description = "Availability zones for public subnets"
  type        = list(string)
}

variable "pub-sub-name" {
  description = "Name prefix for public subnets"
}

variable "pri-subnet-count" {
  description = "Number of private subnets"
}

variable "pri-cidr-block" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "pri-availability-zone" {
  description = "Availability zones for private subnets"
  type        = list(string)
}

variable "pri-sub-name" {
  description = "Name prefix for private subnets"
}

variable "public-rt-name" {
  description = "Name of the public route table"
}

variable "private-rt-name" {
  description = "Name of the private route table"
}

variable "pip-name" {
  description = "Name of the public IP for NAT Gateway"
}

variable "nat-name" {
  description = "Name of the NAT Gateway"
}

variable "aks-sg" {
  description = "Name of the Network Security Group for AKS"
}
# AKS
variable "is-aks-cluster-enabled" {
  description = "Whether to enable AKS cluster creation"
  type        = bool
  default     = true
}

variable "cluster-version" {
  description = "Kubernetes version for the AKS cluster"
}

variable "private-cluster-enabled" {
  description = "Whether to enable private AKS cluster"
  type        = bool
}

variable "public-network-access-enabled" {
  description = "Whether to enable public network access to AKS API"
  type        = bool
}

variable "system_node_pool_vm_size" {
  description = "VM size for system node pool"
  default     = "Standard_DS2_v2"
}

variable "user_node_pool_vm_sizes" {
  description = "VM sizes for user node pools"
  type        = list(string)
}

variable "system_node_pool_desired_count" {
  description = "Desired node count for system node pool"
}

variable "system_node_pool_min_count" {
  description = "Minimum node count for system node pool"
}

variable "system_node_pool_max_count" {
  description = "Maximum node count for system node pool"
}

variable "user_node_pool_desired_count" {
  description = "Desired node count for user node pool"
}

variable "user_node_pool_min_count" {
  description = "Minimum node count for user node pool"
}

variable "user_node_pool_max_count" {
  description = "Maximum node count for user node pool"
}

variable "addons" {
  description = "Addons for AKS"
  type = list(object({
    name    = string
    enabled = bool
  }))
}

locals {
  org = "medium"
  env = var.env
}
