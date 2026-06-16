
################ Linked Services ################
resource "azurerm_data_factory_linked_custom_service" "name" {
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
