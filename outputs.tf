output "libre_chat_url" {
  value = "${azurerm_linux_web_app.librechat.name}.azurewebsites.net"
}

output "azure_openai_api_key" {
  value = "${module.openai.openai_primary_key}"
  sensitive = true
}

output "azure_openai_endpoint" {
  value = "${module.openai.openai_endpoint}"
  sensitive = true
}