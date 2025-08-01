# Intersight Certificate Policy - Terraform Deployment

This Terraform configuration automates the deployment of Cisco Intersight Certificate Policies. It provides a declarative approach to managing certificate policies with support for CA certificate and server (IMC) certificate/key pairs.

## Overview

The configuration automatically discovers certificate files, validates them, and creates policies with appropriate tagging for environment management.

## Architecture

- **Provider**: Cisco Intersight Terraform Provider
- **Resources**: Certificate Management Policy

## Prerequisites

### Required Software
- Terraform >= 1.0
- Cisco Intersight account with API access
- Valid certificate files in PEM format

### Required Intersight Permissions
- Certificate Management Policy: Create, Read, Update, Delete

### Certificate Files
The following certificate files should be present in the specified certificate directory:
- `sample_ca_cert.pem` - CA Certificate (Root CA)
- `sample_server_cert.pem` - Server Certificate
- `sample_server_key.pem` - Server Private Key

## Quick Start

### 1. Setup Intersight API Credentials

1. Login to [Intersight](https://intersight.com)
2. Navigate to Settings → API Keys → Generate API Key
3. Download the `SecretKey.txt` file
4. Note your API Key ID

### 2. Configure Variables

Create or update `terraform.tfvars`:

```hcl
# Intersight Authentication
intersight_api_key_id     = "your-api-key-id"
intersight_secret_key_file = "./SecretKey.txt"
organization_name         = "default"

# Policy Configuration
policy_name        = "Certificate-Policy-Production"
policy_description = "UCS certificate management"
environment        = "Production"
createdDate        = "2025-07-31"

# Certificate Directory
certificate_directory = "."
```

### 3. Deploy

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 4. Verify Deployment

```bash
# Check outputs
terraform output

# View certificate policy in Intersight Console
# Navigate to Policies → Certificate Management
```

## Configuration Reference

### Input Variables

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `intersight_api_key_id` | string | *none* | **Yes** | Intersight API Key ID (sensitive) |
| `intersight_secret_key_file` | string | `"./SecretKey.txt"` | **Yes** | Path to Intersight secret key file |
| `intersight_endpoint` | string | `"https://intersight.com"` | No | Intersight API endpoint |
| `organization_name` | string | `"default"` | No | Intersight organization name (used if organization_moid not provided) |
| `organization_moid` | string | `null` | No | MOID of the Intersight organization (takes precedence over organization_name) |
| `policy_name` | string | `"UCS-Certificate-Policy-01"` | No | Certificate policy name |
| `policy_description` | string | `"UCS certificate policy with CA and server certificate pairs"` | No | Policy description |
| `certificate_directory` | string | `"."` | No | Directory containing certificate files |
| `environment` | string | `"Production"` | No | Environment tag value |

## File Structure

```
terraform/
├── main.tf              # Main configuration with certificate policy
├── variables.tf         # Input variable definitions
├── outputs.tf          # Output definitions
├── versions.tf         # Provider version constraints
├── terraform.tfvars   # Variable values (customize for your environment)
├── README.md          # This documentation
├── sample_ca_cert.pem # CA certificate file
├── sample_server_cert.pem # Server certificate file
├── sample_server_key.pem  # Server private key file
└── SecretKey.txt      # Intersight API secret key
```

### Certificate Rotation

To update certificates:

1. Replace certificate files in the certificate directory
2. Run `terraform plan` to review changes
3. Apply changes with `terraform apply -auto-approve`

## Policy Management

### Checking for Existing Policies

Before creating new policies, you can check what certificate policies already exist in your Intersight organization:

#### Using Terraform Data Source

Create a temporary file to query existing policies:

```bash
# Create temporary policy check file
cat > check_policies.tf << 'EOF'
data "intersight_certificatemanagement_policy" "existing_policies" {
}

output "existing_certificate_policies" {
  description = "All existing certificate policies in the organization"
  value = {
    count = length(data.intersight_certificatemanagement_policy.existing_policies.results)
    policies = [
      for policy in data.intersight_certificatemanagement_policy.existing_policies.results : {
        name         = policy.name
        moid         = policy.moid
        description  = policy.description
        create_time  = policy.create_time
        mod_time     = policy.mod_time
        tags         = policy.tags
      }
    ]
  }
}
EOF

# Query existing policies
terraform apply -target=data.intersight_certificatemanagement_policy.existing_policies -auto-approve

# Clean up temporary file
rm check_policies.tf
terraform refresh
```

## Example Deployment

### Sample terraform apply Output

When you run `terraform apply`, you'll see output similar to this:

```bash
$ terraform apply -auto-approve

data.tls_certificate.ca_cert[0]: Reading...
data.tls_certificate.server_cert[0]: Reading...
data.intersight_organization_organization.org[0]: Reading...
data.tls_certificate.ca_cert[0]: Read complete after 0s
data.tls_certificate.server_cert[0]: Read complete after 0s  
data.intersight_organization_organization.org[0]: Read complete after 1s

Terraform used the selected providers to generate the following execution plan. 
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # intersight_certificatemanagement_policy.certificate_policy will be created
  + resource "intersight_certificatemanagement_policy" "certificate_policy" {
      + class_id             = "certificatemanagement.Policy"
      + create_time          = (known after apply)
      + description          = "UCS certificate management"
      + id                   = (known after apply)
      + moid                 = (known after apply)
      + name                 = "Certificate-Policy-Final-Test"
      + object_type          = "certificatemanagement.Policy"
      + certificates         = [
          + {
              + enabled     = true
              + object_type = "certificatemanagement.RootCaCertificate"
              # CA Certificate configuration...
            },
          + {
              + enabled     = true
              + object_type = "certificatemanagement.Imc"
              # Server Certificate configuration...
            },
        ]
      + tags = [
          + { key = "CreatedDate", value = "2025-07-31" },
          + { key = "Environment", value = "Production" },
        ]
    }

Plan: 1 to add, 0 to change, 0 to destroy.

intersight_certificatemanagement_policy.certificate_policy: Creating...
intersight_certificatemanagement_policy.certificate_policy: Creation complete after 1s [id=688c14666275723101465dca]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

### Sample terraform output Results

After successful deployment, `terraform output` will show:

```bash
$ terraform output

certificate_files_used = {
  "ca_cert_file" = "./sample_ca_cert.pem"
  "server_cert_file" = "./sample_server_cert.pem"
  "server_key_file" = "./sample_server_key.pem"
}
certificate_policy_moid = "688c14666275723101465dca"
certificate_policy_name = "Certificate-Policy-Final-Test"
organization_moid = "659eb6c26972653001645fbe"
```