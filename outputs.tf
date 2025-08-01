# Essential outputs for certificate policy

output "certificate_policy_moid" {
  description = "MOID of the created certificate policy"
  value       = intersight_certificatemanagement_policy.certificate_policy.moid
}

output "certificate_policy_name" {
  description = "Name of the created certificate policy"
  value       = intersight_certificatemanagement_policy.certificate_policy.name
}

output "organization_moid" {
  description = "MOID of the organization used"
  value       = local.organization_moid
}

output "certificate_files_used" {
  description = "Certificate files that were discovered and used"
  value = {
    ca_cert_file     = local.ca_cert_file
    server_cert_file = local.server_cert_file
    server_key_file  = local.server_key_file
  }
}
