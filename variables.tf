# Intersight Certificate Policy Variables

variable "intersight_api_key_id" {
  description = "Intersight API Key ID"
  type        = string
  sensitive   = true
}

variable "intersight_secret_key_file" {
  description = "Path to the Intersight API secret key file"
  type        = string
  default     = "./SecretKey.txt"
}

variable "intersight_endpoint" {
  description = "Intersight API endpoint"
  type        = string
  default     = "https://intersight.com"
}

variable "organization_name" {
  description = "Name of the Intersight organization"
  type        = string
  default     = "default"
}

variable "organization_moid" {
  description = "MOID of the Intersight organization"
  type        = string
  default     = null
}

variable "policy_name" {
  description = "Name of the certificate policy"
  type        = string
  default     = "UCS-Certificate-Policy-01"
}

variable "policy_description" {
  description = "Description of the certificate policy"
  type        = string
  default     = "UCS certificate policy with CA and server certificate pairs"
}

variable "certificate_directory" {
  description = "Directory containing certificate files"
  type        = string
  default     = "."
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "Production"
}

variable "company" {
  description = "Company name for tagging"
  type        = string
  default     = "UCS"
}

variable "custom_tags" {
  description = "Additional custom tags to apply to the certificate policy"
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}

variable "enable_validation" {
  description = "Enable certificate validation checks"
  type        = bool
  default     = true
}
