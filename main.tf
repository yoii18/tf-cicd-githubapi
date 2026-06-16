resource "azurerm_resource_group" "rg_create" {
  location = var.location
  name     = var.rgname
}

module "strgacct_create" {
  source   = "./modules/strgacct"
  location = var.location
  rgname   = var.rgname
  strgname = var.strgacctname

  depends_on = [azurerm_resource_group.rg_create]
}

module "adf_create" {
  source    = "./modules/adf"
  rgname    = var.rgname
  location  = var.location
  name      = var.adfname
  groupname = var.groupname

  depends_on = [azurerm_resource_group.rg_create]
}

module "pl_create" {
  source = "./modules/pl"
  adf_id = module.adf_create.adf_id
}
