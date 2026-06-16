
################ Linked Services ################
resource "azurerm_data_factory_linked_custom_service" "adf_rest_ls" {
  type = "RestService"
  name = "adf_rest_ls"
  type_properties_json = jsonencode({
    enableServerCertificateValidation = true
    url                               = "https://api.github.com/"
    authenticationType                = "Anonymous"
    headers = {
      Accept               = "application/vnd.github+json"
      X-GitHub-Api-Version = "2026-03-10"
    }
  })
  data_factory_id = var.adf_id
}

resource "azurerm_data_factory_linked_custom_service" "adf_adls_ls" {
  type = "AzureBlobFS"
  name = "adf_adls_ls"
  type_properties_json = jsonencode({
    url = "https://${var.strgname}.dfs.core.windows.net"
  })
  data_factory_id = var.adf_id
}
