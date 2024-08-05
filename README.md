# Sentry DSN for AWS

Creates an AWS Secrets Manager secret containing a Sentry DSN for submitting
errors and events to a Sentry project.

A secret containing a Sentry auth token must be provided. Once active, the
secret will automatically rotate credentials every 30 days. In order to avoid
gaps between rotating the secret and restarting applications, two client keys
will be maintained. Whenever the secret is rotated, the oldest will be deleted
and a new DSN will be set.

Example:

```
module "sentry_dsn" {
  source = "github.com/thoughtbot/terraform-aws-sentry-dsn?ref=v0.3.0"

  name              = "example-staging"
  organization_slug = "organization"
  project_slug      = "example"
  subnet_ids        = module.network_data.private_subnet_ids
  vpc_id            = module.network_data.vpc.id

  # You can provide the ARN of a secret containing an auth token. If not
  # provided, it will look for a secret named ORGNIZATION-PROJECT-NAME-sentry
  auth_token_secret_name = "my-secret"
}
```

## Creating an auth token

The recommended approach to generating an auth token is to create an [internal
integration] for Sentry. In order to manage auth tokens, you will need the
following scopes:

- `project:read`
- `project:write`
- `project:admin`

After creating the integration, copy the auth token and save it in a Secrets
Manager secret.

[internal integration]: https://docs.sentry.io/product/integrations/integration-platform/internal-integration/

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 5.0    |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 5.0  |

## Modules

| Name                                                        | Source                                                                | Version |
| ----------------------------------------------------------- | --------------------------------------------------------------------- | ------- |
| <a name="module_rotation"></a> [rotation](#module_rotation) | github.com/thoughtbot/terraform-aws-secrets//secret-rotation-function | v0.8.0  |
| <a name="module_secret"></a> [secret](#module_secret)       | github.com/thoughtbot/terraform-aws-secrets//secret                   | v0.8.0  |

## Resources

| Name                                                                                                                                                       | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.access_auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                 | resource    |
| [aws_iam_role_policy_attachment.access_auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_security_group.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                  | resource    |
| [aws_security_group_rule.function_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)                 | resource    |
| [aws_iam_policy_document.access_auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)            | data source |
| [aws_kms_key.auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key)                                           | data source |
| [aws_secretsmanager_secret.auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret)               | data source |

## Inputs

| Name                                                                                                | Description                                                           | Type           | Default                     | Required |
| --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | -------------- | --------------------------- | :------: |
| <a name="input_admin_principals"></a> [admin_principals](#input_admin_principals)                   | Principals allowed to peform admin actions (default: current account) | `list(string)` | `null`                      |    no    |
| <a name="input_auth_token_kms_key_id"></a> [auth_token_kms_key_id](#input_auth_token_kms_key_id)    | ID of the KMS key used to encrypt the auth token                      | `string`       | `"alias/sentry-auth-token"` |    no    |
| <a name="input_auth_token_secret_arn"></a> [auth_token_secret_arn](#input_auth_token_secret_arn)    | ARN of a SecretsManager secret containing a Sentry auth token         | `string`       | `null`                      |    no    |
| <a name="input_auth_token_secret_key"></a> [auth_token_secret_key](#input_auth_token_secret_key)    | Key within secret at which the auth token ca be accessed              | `string`       | `"SENTRY_AUTH_TOKEN"`       |    no    |
| <a name="input_auth_token_secret_name"></a> [auth_token_secret_name](#input_auth_token_secret_name) | Name of a SecretsManager secret containing a Sentry auth token        | `string`       | `"sentry-auth-token"`       |    no    |
| <a name="input_name"></a> [name](#input_name)                                                       | Name for the Sentry client key                                        | `string`       | n/a                         |   yes    |
| <a name="input_organization_slug"></a> [organization_slug](#input_organization_slug)                | Slug for the Sentry organization in which the project exists          | `string`       | n/a                         |   yes    |
| <a name="input_project_slug"></a> [project_slug](#input_project_slug)                               | Slug for the Sentry project for which a key should be created         | `string`       | n/a                         |   yes    |
| <a name="input_read_principals"></a> [read_principals](#input_read_principals)                      | Principals allowed to read the secret (default: current account)      | `list(string)` | `null`                      |    no    |
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids)                                     | Subnets in which the rotation function should run                     | `list(string)` | n/a                         |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                       | Tags which should be applied to created resources                     | `map(string)`  | `{}`                        |    no    |
| <a name="input_trust_tags"></a> [trust_tags](#input_trust_tags)                                     | Tags required on principals accessing the secret                      | `map(string)`  | `{}`                        |    no    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                 | VPC in which the rotation function should run                         | `string`       | n/a                         |   yes    |

## Outputs

| Name                                                                 | Description                                               |
| -------------------------------------------------------------------- | --------------------------------------------------------- |
| <a name="output_policy_json"></a> [policy_json](#output_policy_json) | Required IAM policies                                     |
| <a name="output_secret_arn"></a> [secret_arn](#output_secret_arn)    | ARN of the secrets manager secret containing credentials  |
| <a name="output_secret_name"></a> [secret_name](#output_secret_name) | Name of the secrets manager secret containing credentials |

<!-- END_TF_DOCS -->
