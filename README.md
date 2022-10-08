# GCP-COMPUTE

This repository consists of Terraform templates to create GCP compute object.

## Usage

- Clone this repo with: `git clone --recurse-submodules https://github.com/cklewar/gcp-compute`
- Enter repository directory with: `cd gcp-compute`
- Obtain F5XC API certificate file from Console and save it to `cert` directory
- Pick and choose from below examples and add mandatory input data and copy data into file `main.tf.example`.
- Rename file __main.tf.example__ to __main.tf__ with: `rename main.tf.example main.tf`
- Initialize with: `terraform init`
- Apply with: `terraform apply -auto-approve` or destroy with: `terraform destroy -auto-approve`

### Example Output

```bash

```

## Vnet Hub and Spoke module usage example

````hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
  default     = "f5xc"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
  default     = "01"
}

variable "f5xc_namespace" {
  type    = string
  default = "system"
}

variable "f5xc_azure_region" {
  type    = string
  default = "eastus"
}

variable "f5xc_api_p12_file" {
  type    = string
}

variable "f5xc_api_url" {
  type    = string
}

variable "f5xc_tenant" {
  type    = string
}

variable "f5xc_api_token" {
  type    = string
}

variable "public_ssh_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCXwW/k3C+Ny9U7JnIsiTmuCKQoieIe4prd/8yPVKiLkv6K6ZaZKn3yzqNr6HebWHrXgiUa9xs7BKg//mkPFeF18QYombyutIa43fN8O3LZu+BbgtN5jtMyr7oqlJ14m9EvgaWS6r/8afPNX2F9i31u3rRYTzJCEUAiQGb6YHUSH8HT8GbBokz53mua9aWgOZSmXtaDa1yCjiqqjQO80ZkAI1Tfqe0a9UNjerLpDW1uBoXt/3MbkjO/N/IK4BL7544z/aTfnumKlSdpi61ifRw8jPolDKuFN2LFWi6WtyP11lSAcQlp3g9Qh9cJzY6xqKkwFzC76D6TCi9bvIjLHr/FA/XffH3xwerjuBE0OgsyHr/o6SmCs5anjN1CHY4j9BfnswB1iXq/cnSRBuN0U4v80NwkWcwhgUgTxmVUejcFeQpa5AOsr0XLCW6jyeAk6U0CrwW/Auvc5MMzvAUh5IBnKWXQ8NITdF+304+n/wJq7jc1jfiRvn+rFEUfXAExV+k= c.klewar@HDY0C349LN"
}

variable "f5xc_azure_cred" {
  type    = string
  default = "sun-az-creds"
}

variable "azure_client_id" {
  type    = string
}

variable "azure_client_secret" {
  type    = string
}

variable "azure_tenant_id" {
  type    = string
}

variable "azure_subscription_id" {
  type    = string
}

module "f5xc_azure_marketplace_agreement" {
  source                = "./modules/azure/agreement"
  f5xc_azure_ce_gw_type = "multi_nic"
  azure_client_id       = var.azure_client_id
  azure_client_secret   = var.azure_client_secret
  azure_tenant_id       = var.azure_tenant_id
  azure_subscription_id = var.azure_subscription_id

}

module "azure_vnet_spoke_a" {
  source                       = "./modules/f5xc/site/azure"
  f5xc_api_p12_file            = var.f5xc_api_p12_file
  f5xc_api_url                 = var.f5xc_api_url
  f5xc_namespace               = var.f5xc_namespace
  f5xc_tenant                  = var.f5xc_tenant
  f5xc_azure_cred              = var.f5xc_azure_cred
  f5xc_azure_region            = var.f5xc_azure_region
  f5xc_azure_site_name         = format("%s-vnet-spoke-a-%s", var.project_prefix, var.project_suffix)
  f5xc_azure_vnet_primary_ipv4 = "192.168.168.0/21"
  f5xc_azure_ce_gw_type        = "single_nic"
  f5xc_azure_az_nodes          = {
    node0 : { f5xc_azure_az = "1", f5xc_azure_vnet_local_subnet = "192.168.168.0/24" },
  }
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_ce_os_version    = true
  f5xc_azure_no_worker_nodes          = false
  f5xc_azure_total_worker_nodes       = 0
  public_ssh_key                      = var.public_ssh_key
}

module "azure_vnet_spoke_a_wait_for_online" {
  depends_on     = [module.azure_vnet_spoke_a]
  source         = "./modules/f5xc/status/site"
  f5xc_api_token = var.f5xc_api_token
  f5xc_api_url   = var.f5xc_api_url
  f5xc_namespace = var.f5xc_namespace
  f5xc_tenant    = var.f5xc_tenant
  f5xc_site_name = format("%s-vnet-spoke-a-%s", var.project_prefix, var.project_suffix)
}

module "azure_vnet_spoke_b" {
  source                       = "./modules/f5xc/site/azure"
  f5xc_api_p12_file            = var.f5xc_api_p12_file
  f5xc_api_url                 = var.f5xc_api_url
  f5xc_namespace               = var.f5xc_namespace
  f5xc_tenant                  = var.f5xc_tenant
  f5xc_azure_cred              = var.f5xc_azure_cred
  f5xc_azure_region            = var.f5xc_azure_region
  f5xc_azure_site_name         = format("%s-vnet-spoke-b-%s", var.project_prefix, var.project_suffix)
  f5xc_azure_vnet_primary_ipv4 = "192.168.176.0/21"
  f5xc_azure_ce_gw_type        = "single_nic"
  f5xc_azure_az_nodes          = {
    node0 : { f5xc_azure_az = "1", f5xc_azure_vnet_local_subnet = "192.168.176.0/24" },
  }
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_ce_os_version    = true
  f5xc_azure_no_worker_nodes          = false
  f5xc_azure_total_worker_nodes       = 0
  public_ssh_key                      = var.public_ssh_key
}

module "azure_vnet_spoke_b_wait_for_online" {
  depends_on     = [module.azure_vnet_spoke_b]
  source         = "./modules/f5xc/status/site"
  f5xc_api_token = var.f5xc_api_token
  f5xc_api_url   = var.f5xc_api_url
  f5xc_namespace = var.f5xc_namespace
  f5xc_tenant    = var.f5xc_tenant
  f5xc_site_name = format("%s-vnet-spoke-b-%s", var.project_prefix, var.project_suffix)
}

module "azure_multi_node_multi_nic_new_vnet_hub_spoke_vnets" {
  source                       = "./modules/f5xc/site/azure"
  f5xc_api_p12_file            = var.f5xc_api_p12_file
  f5xc_api_url                 = var.f5xc_api_url
  f5xc_namespace               = var.f5xc_namespace
  f5xc_tenant                  = var.f5xc_tenant
  f5xc_azure_cred              = var.f5xc_azure_cred
  f5xc_azure_region            = var.f5xc_azure_region
  f5xc_azure_site_name         = format("%s-mn-m-nic-n-vnet-hub-spoke-vnets-%s", var.project_prefix, var.project_suffix)
  f5xc_azure_vnet_primary_ipv4 = "100.64.16.0/20"
  f5xc_azure_ce_gw_type        = "multi_nic"
  f5xc_azure_az_nodes          = {
    node0 : {
      f5xc_azure_az                  = "1", f5xc_azure_vnet_inside_subnet = "100.64.16.0/24",
      f5xc_azure_vnet_outside_subnet = "100.64.17.0/24"
    }
  }
  f5xc_azure_hub_spoke_vnets = [
    {
      resource_group = module.azure_vnet_spoke_a.vnet.vnet_resource_group
      vnet_name      = module.azure_vnet_spoke_a.vnet.name
      auto           = true
      manual         = false
      labels         = {
        "keyA" = "ValueA"
      }
    },
    {
      resource_group = module.azure_vnet_spoke_b.vnet.vnet_resource_group
      vnet_name      = module.azure_vnet_spoke_b.vnet.name
      auto           = true
      manual         = false
      labels         = {
        "keyB" = "ValueB"
      }
    }
  ]
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_ce_os_version    = true
  f5xc_azure_no_worker_nodes          = true
  f5xc_azure_total_worker_nodes       = 0
  public_ssh_key                      = var.public_ssh_key
}

module "azure_multi_node_multi_nic_new_vnet_hub_spoke_vnets_wait_for_online" {
  depends_on     = [module.azure_multi_node_multi_nic_new_vnet_hub_spoke_vnets]
  source         = "./modules/f5xc/status/site"
  f5xc_api_token = var.f5xc_api_token
  f5xc_api_url   = var.f5xc_api_url
  f5xc_namespace = var.f5xc_namespace
  f5xc_tenant    = var.f5xc_tenant
  f5xc_site_name = format("%s-mn-m-nic-n-vnet-hub-spoke-vnets-%s", var.project_prefix, var.project_suffix)
}
````


