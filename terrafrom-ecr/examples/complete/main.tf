provider "aws" {
  region = local.region
}

locals {
  region = "eu-central-1"
  name   = "packages/service2"

  account_id = data.aws_caller_identity.current.account_id

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecr"
  }
}

data "aws_caller_identity" "current" {}

################################################################################
# ECR Repository
################################################################################

module "ecr_disabled" {
  source = "../.."

  create = false
}

module "ecr" {
  source = "../.."

  repository_name = local.name

  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  create_lifecycle_policy           = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_force_delete = true

  tags = local.tags
}

module "ecr_registry" {
  source = "../.."

  create_repository = false

  # Registry Policy
  create_registry_policy = true
  registry_policy        = data.aws_iam_policy_document.registry.json

  # Registry Pull Through Cache Rules
  registry_pull_through_cache_rules = {
    pub = {
      ecr_repository_prefix = "ecr-public"
      upstream_registry_url = "public.ecr.aws"
    }
    dockerhub = {
      ecr_repository_prefix = "dockerhub"
      upstream_registry_url = "registry-1.docker.io"
      credential_arn        = module.secrets_manager_dockerhub_credentials.secret_arn
    }
  }

  # Registry Scanning Configuration
  manage_registry_scanning_configuration = true
  registry_scan_type                     = "ENHANCED"
  registry_scan_rules = [
    {
      scan_frequency = "SCAN_ON_PUSH"
      filter = [
        {
          filter      = "example1"
          filter_type = "WILDCARD"
        },
        { filter      = "example2"
          filter_type = "WILDCARD"
        }
      ]
      }, {
      scan_frequency = "CONTINUOUS_SCAN"
      filter = [
        {
          filter      = "example"
          filter_type = "WILDCARD"
        }
      ]
    }
  ]
