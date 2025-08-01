# Certificate validation data sources

data "tls_certificate" "ca_cert" {
  count   = var.enable_validation && local.ca_cert_content != null ? 1 : 0
  content = local.ca_cert_content
}

data "tls_certificate" "server_cert" {
  count   = var.enable_validation && local.server_cert_content != null ? 1 : 0
  content = local.server_cert_content
}
