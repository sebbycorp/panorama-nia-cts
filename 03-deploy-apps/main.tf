
data "terraform_remote_state" "environment" {
  backend = "local"

  config = {
    path = "../01-infra-cloud/terraform.tfstate"
  }
}

module "web-tier" {
  source = "./web-tier"
  resource_group_name = data.terraform_remote_state.environment.outputs.azurerm_resource_group
  location = data.terraform_remote_state.environment.outputs.location
  owner = data.terraform_remote_state.environment.outputs.owner
  web_subnet     = data.terraform_remote_state.environment.outputs.app_network_web_subnet
  consul_server_ip       = data.terraform_remote_state.environment.outputs.consul-ip
  web-id = data.terraform_remote_state.environment.outputs.web-id
  app-lb = data.terraform_remote_state.environment.outputs.vaultlb
  web_count = var.web_count
}

module "app-tier" {
  source = "./app-tier"
  resource_group_name = data.terraform_remote_state.environment.outputs.azurerm_resource_group
  location = data.terraform_remote_state.environment.outputs.location
  owner = data.terraform_remote_state.environment.outputs.owner
  app_subnet     = data.terraform_remote_state.environment.outputs.app_network_app_subnet
  consul_server_ip       = data.terraform_remote_state.environment.outputs.consul-ip
  app-id = data.terraform_remote_state.environment.outputs.app-id
  app_count = var.app_count
}

module "api-tier" {
  source = "./api-tier"
  aws_subnet     = data.terraform_remote_state.environment.outputs.aws-public-subnet
  owner = data.terraform_remote_state.environment.outputs.owner
  consul_server_ip       = data.terraform_remote_state.environment.outputs.consul-public-ip
  vpc_id = data.terraform_remote_state.environment.outputs.vpc_id
  aws_api_count = var.aws_api_count
}
