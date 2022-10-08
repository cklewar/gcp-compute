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

## GCP compute module usage example

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

variable "ssh_public_key_file" {
  type    = string
}

variable "gcp_region" {
  type    = string
  default = "us-east1"
}

variable "gcp_zone" {
  type    = string
  default = "us-east1-b"
}

variable "gcp_credentials_file_path" {
  type = string
}

variable "gcp_project_id" {
  type    = string
}

variable "gcp_google_credentials" {
  type    = string
}

provider "google" {
  credentials = var.gcp_google_credentials
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
  alias       = "default"
}

module "gcp_network" {
  source                   = "./modules/gcp/network"
  gcp_compute_network_name = format("%s-network-%s", var.project_prefix, var.project_suffix)
  gcp_project_name         = var.gcp_project_id
  providers                = {
    google = google.default
  }
}

module "gcp_subnetwork" {
  source                               = "./modules/gcp/subnetwork"
  gcp_compute_network_id               = module.gcp_network.vpc_network["id"]
  gcp_compute_subnetwork_ip_cidr_range = "172.16.24.0/21"
  gcp_compute_subnetwork_name          = format("%s-subnetwork-%s", var.project_prefix, var.project_suffix)
  gcp_region                           = var.gcp_region
  providers                            = {
    google = google.default
  }
}

module "gcp_compute_instance" {
  source                                  = "./modules/gcp/compute"
  gcp_compute_instance_machine_name       = format("%s-gcp-compute-%s", var.project_prefix, var.project_suffix)
  gcp_zone_name                           = var.gcp_zone
  public_ssh_key                          = file(var.ssh_public_key_file)
  gcp_compute_instance_network_interfaces = [
    {
      subnetwork_name = module.gcp_subnetwork.subnetwork["id"]
      access_config   = {}
    }
  ]
  providers = {
    google = google.default
  }
}

module "gcp_compute_firewall" {
  source                       = "./modules/gcp/firewall"
  compute_firewall_allow_rules = [
    {
      protocol = "tcp"
      port     = ["22"]
    }
  ]
  gcp_compute_firewall_compute_network = module.gcp_network.vpc_network["name"]
  gcp_compute_firewall_name            = format("%s-%s-fw-%s", var.project_prefix, module.gcp_compute_instance.gcp_compute["name"], var.project_suffix)
  gcp_compute_firewall_source_ranges   = ["0.0.0.0/0"]
  gcp_project_name                     = var.gcp_project_id
  providers                            = {
    google = google.default
  }
}

````


