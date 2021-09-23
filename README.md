# Sentry DSN

Provides a Sentry DSN for submitting errors and events to a Sentry project.

A secret containing a Sentry auth token must be provided. Once active, the
secret will automatically rotate credentials every 30 days. In order to avoid
gaps between rotating the secret and restarting applications, two client keys
will be maintained. Whenever the secret is rotated, the oldest will be deleted
and a new DSN will be set.

Example:

```
module "sentry_dsn" {
  source = "git@github.com:thoughtbot/flightdeck-addons.git//aws/sentry-dsn?ref=main"

  name              = "example-staging"
  organization_slug = "organization"
  project_slug      = "example"
  subnet_ids        = module.network_data.private_subnet_ids
  vpc_id            = module.network_data.vpc.id
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.45 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.45 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rotation"></a> [rotation](#module\_rotation) | ../secret-rotation-function |  |
| <a name="module_secret"></a> [secret](#module\_secret) | ../generic-secret |  |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.access_auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.access_auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.function_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_policy_document.access_auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_secretsmanager_secret.auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_token_kms_key_id"></a> [auth\_token\_kms\_key\_id](#input\_auth\_token\_kms\_key\_id) | ID of the KMS key used to encrypt the auth token | `string` | `"alias/sentry-auth-token"` | no |
| <a name="input_auth_token_secret_arn"></a> [auth\_token\_secret\_arn](#input\_auth\_token\_secret\_arn) | ARN of a SecretsManager secret containing a Sentry auth token | `string` | `null` | no |
| <a name="input_auth_token_secret_key"></a> [auth\_token\_secret\_key](#input\_auth\_token\_secret\_key) | Key within secret at which the auth token ca be accessed | `string` | `"SENTRY_AUTH_TOKEN"` | no |
| <a name="input_auth_token_secret_name"></a> [auth\_token\_secret\_name](#input\_auth\_token\_secret\_name) | Name of a SecretsManager secret containing a Sentry auth token | `string` | `"sentry-auth-token"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Sentry client key | `string` | n/a | yes |
| <a name="input_organization_slug"></a> [organization\_slug](#input\_organization\_slug) | Slug for the Sentry organization in which the project exists | `string` | n/a | yes |
| <a name="input_project_slug"></a> [project\_slug](#input\_project\_slug) | Slug for the Sentry project for which a key should be created | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets in which the rotation function should run | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags which should be applied to created resources | `map(string)` | `{}` | no |
| <a name="input_trust_principal"></a> [trust\_principal](#input\_trust\_principal) | Principal allowed to access the secret (default: current account) | `string` | `null` | no |
| <a name="input_trust_tags"></a> [trust\_tags](#input\_trust\_tags) | Tags required on principals accessing the secret | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC in which the rotation function should run | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_json"></a> [policy\_json](#output\_policy\_json) | Required IAM policies |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | ARN of the secrets manager secret containing credentials |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | Name of the secrets manager secret containing credentials |
<!-- END_TF_DOCS -->
