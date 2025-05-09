terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.65.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "dev-terraform-state-rg"
    storage_account_name = "devterraformstatehari"
    container_name       = "tfstate"
    key                  = "aks/terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    api_management {
      purge_soft_delete_on_destroy = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
  skip_provider_registration = true
}

module "aks" {
  source = "./modules"  
  azure-region          = var.azure-region  
  
  env                   = var.env
  cluster-name          = "${local.env}-${local.org}-${var.cluster-name}"
  vnet-cidr-block       = var.vnet-cidr-block
  vnet-name             = "${local.env}-${local.org}-${var.vnet-name}"
  pub-subnet-count      = var.pub-subnet-count
  pub-cidr-block        = var.pub-cidr-block
  pub-availability-zone = var.pub-availability-zone
  pub-sub-name          = "${local.env}-${local.org}-${var.pub-sub-name}"
  pri-subnet-count      = var.pri-subnet-count
  pri-cidr-block        = var.pri-cidr-block
  pri-availability-zone = var.pri-availability-zone
  pri-sub-name          = "${local.env}-${local.org}-${var.pri-sub-name}"
  public-rt-name        = "${local.env}-${local.org}-${var.public-rt-name}"
  private-rt-name       = "${local.env}-${local.org}-${var.private-rt-name}"
  pip-name              = "${local.env}-${local.org}-${var.pip-name}"
  nat-name              = "${local.env}-${local.org}-${var.nat-name}"
  aks-sg                = var.aks-sg

  is-aks-cluster-enabled          = var.is-aks-cluster-enabled
  cluster-version                 = var.cluster-version
  private-cluster-enabled         = var.private-cluster-enabled
  public-network-access-enabled   = var.public-network-access-enabled
  system_node_pool_vm_size        = var.system_node_pool_vm_size
  user_node_pool_vm_sizes         = var.user_node_pool_vm_sizes
  system_node_pool_desired_count  = var.system_node_pool_desired_count
  system_node_pool_min_count      = var.system_node_pool_min_count
  system_node_pool_max_count      = var.system_node_pool_max_count
  user_node_pool_desired_count    = var.user_node_pool_desired_count
  user_node_pool_min_count        = var.user_node_pool_min_count
  user_node_pool_max_count        = var.user_node_pool_max_count

  addons                          = var.addons
}