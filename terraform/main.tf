terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "ws-devops"
    storage_account_name = "devopshackathontfstate"
    container_name       = "tfstate"
    key                  = "piytts123.tfstate"
  }
}

provider "azurerm" {
  features {}
}

#Get resource group
data "azurerm_resource_group" "wsdevops" {
  name = var.rg_name
}

resource "azurerm_app_service_plan" "sp1" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.wsdevops.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "website" {
  name                = var.web_app_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.wsdevops.name
  app_service_plan_id = azurerm_app_service_plan.sp1.id

  site_config {
    linux_fx_version = "NODE|22-lts"
    scm_type         = "LocalGit"
  }
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "piystt-lg-analytics"
  location            = data.azurerm_resource_group.wsdevops.location
  resource_group_name = data.azurerm_resource_group.wsdevops.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "appi" {
  name                = "piystt123-api"
  location            = data.azurerm_resource_group.wsdevops.location
  resource_group_name = data.azurerm_resource_group.wsdevops.name
  workspace_id        = azurerm_log_analytics_workspace.log.id
  application_type    = "web"
}

// Skeleton for linking web app and app insights
resource "null_resource" "link_monitoring" {
  provisioner "local-exec" {
    command = <<EOT
      # Login to Azure CLI (Linux operating system assumed)
      az login --service-principal -u $con_client_id -p $con_client_secret --tenant $con_tenant_id
      # TODO your scripting code
    EOT
    environment = {
      // Parameters needed to login
      con_client_id     = TODO
      con_client_secret = TODO
      con_tenant_id     = TODO
      // Parameters needed for linking
      inst_key          = TODO
      conn_str          = TODO      
      rg_name           = TODO
      web_app_name      = TODO
    }
  }
}
