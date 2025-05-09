resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.env}-${var.cluster-name}-rg"
  location = var.azure-region

  tags = {
    Environment = var.env
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet-name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = [var.vnet-cidr-block]

  tags = {
    Name        = var.vnet-name
    Environment = var.env
  }
}

resource "azurerm_subnet" "public-subnet" {
  count                = var.pub-subnet-count
  name                 = "${var.pub-sub-name}-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [element(var.pub-cidr-block, count.index)]
}

resource "azurerm_subnet" "private-subnet" {
  count                = var.pri-subnet-count
  name                 = "${var.pri-sub-name}-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [element(var.pri-cidr-block, count.index)]
}

resource "azurerm_public_ip" "nat_pip" {
  name                = var.pip-name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = {
    Name = var.pip-name
  }
}

resource "azurerm_nat_gateway" "natgw" {
  name                    = var.nat-name
  location                = azurerm_resource_group.aks_rg.location
  resource_group_name     = azurerm_resource_group.aks_rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10

  tags = {
    Name = var.nat-name
  }
}

resource "azurerm_nat_gateway_public_ip_association" "natgw_pip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

resource "azurerm_subnet_nat_gateway_association" "private_nat_assoc" {
  count          = var.pri-subnet-count
  subnet_id      = azurerm_subnet.private-subnet[count.index].id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

resource "azurerm_route_table" "public_rt" {
  name                = var.public-rt-name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  route {
    name                   = "internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
  }

  tags = {
    Name        = var.public-rt-name
    Environment = var.env
  }
}

resource "azurerm_route_table" "private_rt" {
  name                = var.private-rt-name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  tags = {
    Name        = var.private-rt-name
    Environment = var.env
  }
}

resource "azurerm_subnet_route_table_association" "public_rt_assoc" {
  count          = var.pub-subnet-count
  subnet_id      = azurerm_subnet.public-subnet[count.index].id
  route_table_id = azurerm_route_table.public_rt.id
}

resource "azurerm_subnet_route_table_association" "private_rt_assoc" {
  count          = var.pri-subnet-count
  subnet_id      = azurerm_subnet.private-subnet[count.index].id
  route_table_id = azurerm_route_table.private_rt.id
}

resource "azurerm_network_security_group" "aks_nsg" {
  name                = var.aks-sg
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "AllowAPIServerInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*" # Consider restricting this in production
    destination_address_prefix = "*"
  }

  tags = {
    Name = var.aks-sg
  }
}

resource "azurerm_subnet_network_security_group_association" "private_nsg_assoc" {
  count                     = var.pri-subnet-count
  subnet_id                 = azurerm_subnet.private-subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}
