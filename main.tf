module "secret" {
  source = "github.com/thoughtbot/terraform-aws-secrets//secret?ref=v0.4.0"

  admin_principals = var.admin_principals
  description      = "Sentry DSN: ${var.name}"
  name             = local.full_name
  read_principals  = var.read_principals
  resource_tags    = var.tags
  trust_tags       = var.trust_tags

  initial_value = jsonencode({
    SENTRY_DSN      = ""
    SENTRY_KEY_NAME = ""
  })
}

module "rotation" {
  source = "github.com/thoughtbot/terraform-aws-secrets//secret-rotation-function?ref=v0.4.0"

  handler            = "lambda_function.lambda_handler"
  role_arn           = module.secret.rotation_role_arn
  runtime            = "python3.8"
  secret_arn         = module.secret.arn
  security_group_ids = [aws_security_group.function.id]
  source_file        = "${path.module}/rotation/lambda_function.py"
  subnet_ids         = var.subnet_ids

  variables = {
    AUTH_TOKEN_SECRET_ARN = local.auth_token_secret_arn
    AUTH_TOKEN_SECRET_KEY = var.auth_token_secret_key
    ORGANIZATION_SLUG     = var.organization_slug
    PROJECT_SLUG          = var.project_slug
    CLIENT_KEY_NAME       = var.name
  }
}

resource "aws_iam_role_policy_attachment" "access_auth_token" {
  policy_arn = aws_iam_policy.access_auth_token.arn
  role       = module.secret.rotation_role_name
}

resource "aws_iam_policy" "access_auth_token" {
  name   = local.full_name
  policy = data.aws_iam_policy_document.access_auth_token.json
}

data "aws_iam_policy_document" "access_auth_token" {
  statement {
    sid = "ReadAuthToken"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]
    resources = [local.auth_token_secret_arn]
  }

  statement {
    sid = "DecryptAuthToken"
    actions = [
      "kms:Decrypt"
    ]
    resources = [data.aws_kms_key.auth_token.arn]
  }
}

resource "aws_security_group" "function" {
  description = "Security group for rotation ${var.name} DSN"
  name_prefix = "${local.full_name}-rotation"
  tags        = var.tags
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "function_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.function.id
  to_port           = 0
  type              = "egress"
}

data "aws_secretsmanager_secret" "auth_token" {
  count = var.auth_token_secret_arn == null ? 1 : 0

  name = var.auth_token_secret_name
}

data "aws_kms_key" "auth_token" {
  key_id = var.auth_token_kms_key_id
}

locals {
  auth_token_secret_arn = (
    var.auth_token_secret_arn == null ?
    join("", data.aws_secretsmanager_secret.auth_token.*.arn) :
    var.auth_token_secret_arn
  )

  full_name = join(
    "-",
    distinct(
      split(
        "-",
        replace(
          join(
            "-",
            [var.organization_slug, var.project_slug, var.name, "sentry"]
          ),
          "_",
          "-"
        )
      )
    )
  )
}
