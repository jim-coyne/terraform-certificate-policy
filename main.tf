# Intersight Certificate Policy Management with Terraform

provider "intersight" {
  apikey    = var.intersight_api_key_id
  secretkey = var.intersight_secret_key_file
  endpoint  = var.intersight_endpoint
}

data "intersight_organization_organization" "org" {
  count = var.organization_moid == null ? 1 : 0
  name  = var.organization_name
}

locals {
  organization_moid = var.organization_moid != null ? var.organization_moid : data.intersight_organization_organization.org[0].results[0].moid
  
  ca_cert_file    = "${var.certificate_directory}/sample_ca_cert.pem"
  server_cert_file = "${var.certificate_directory}/sample_server_cert.pem"
  server_key_file  = "${var.certificate_directory}/sample_server_key.pem"
  
  ca_cert_content     = fileexists(local.ca_cert_file) ? file(local.ca_cert_file) : null
  server_cert_content = fileexists(local.server_cert_file) ? file(local.server_cert_file) : null
  server_key_content  = fileexists(local.server_key_file) ? file(local.server_key_file) : null
  
  ca_cert_exists     = fileexists(local.ca_cert_file)
  server_cert_exists = fileexists(local.server_cert_file)
  server_key_exists  = fileexists(local.server_key_file)
  
  ca_cert_base64     = local.ca_cert_content != null ? base64encode(local.ca_cert_content) : null
  server_cert_base64 = local.server_cert_content != null ? base64encode(local.server_cert_content) : null
  server_key_base64  = local.server_key_content != null ? base64encode(local.server_key_content) : null
  
  default_tags = [
    {
      key   = "Environment"
      value = var.environment
    },
    {
      key   = "CreatedDate"
      value = "2025-07-31"
    }
  ]
  
  all_tags = local.default_tags
}

resource "intersight_certificatemanagement_policy" "certificate_policy" {
  name        = var.policy_name
  description = var.policy_description
  
  organization {
    object_type = "organization.Organization"
    moid        = local.organization_moid
  }

  dynamic "certificates" {
    for_each = local.ca_cert_exists ? [1] : []
    content {
      certificate { 
        additional_properties = jsonencode({
          PemCertificate = local.ca_cert_base64
        }) 
      }
      additional_properties = jsonencode({
        CertificateName = "RootCA"
      })
      enabled     = true
      object_type = "certificatemanagement.RootCaCertificate"
    }
  }
  
  dynamic "certificates" {
    for_each = local.server_cert_exists && local.server_key_exists ? [1] : []
    content {
      certificate { 
        additional_properties = jsonencode({
          PemCertificate = local.server_cert_base64
        }) 
      }
      additional_properties = jsonencode({
        CertType   = "None"
        Privatekey = local.server_key_base64
      })
      enabled     = true
      object_type = "certificatemanagement.Imc"
    }
  }

  dynamic "tags" {
    for_each = local.all_tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
