# Terraform versions and provider requirements
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">= 1.0.32"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
