variable "auth_token_secret_arn" {
  type        = string
  description = "ARN of a SecretsManager secret containing a Sentry auth token"
  default     = null
}

variable "auth_token_secret_name" {
  type        = string
  description = "Name of a SecretsManager secret containing a Sentry auth token"
  default     = "sentry-auth-token"
}

variable "auth_token_secret_key" {
  type        = string
  description = "Key within secret at which the auth token ca be accessed"
  default     = "SENTRY_AUTH_TOKEN"
}

variable "auth_token_kms_key_id" {
  type        = string
  description = "ID of the KMS key used to encrypt the auth token"
  default     = "alias/sentry-auth-token"
}

variable "name" {
  type        = string
  description = "Name for the Sentry client key"
}

variable "organization_slug" {
  type        = string
  description = "Slug for the Sentry organization in which the project exists"
}

variable "project_slug" {
  type        = string
  description = "Slug for the Sentry project for which a key should be created"
}

variable "tags" {
  description = "Tags which should be applied to created resources"
  default     = {}
  type        = map(string)
}

variable "trust_principal" {
  description = "Principal allowed to access the secret (default: current account)"
  type        = string
  default     = null
}

variable "trust_tags" {
  description = "Tags required on principals accessing the secret"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Subnets in which the rotation function should run"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC in which the rotation function should run"
  type        = string
}
