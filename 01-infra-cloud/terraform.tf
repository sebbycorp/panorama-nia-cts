terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.11.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.25.0"
    }
    random = {
      source = "hashicorp/random"
    }
      aws = {
      source  = "hashicorp/aws"
      version = "4.32.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "aws" {
  region = var.region
}