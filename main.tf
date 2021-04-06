terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  profile  = "default"
}

locals {
  keys = yamldecode(file("./params.yaml"))["keys"]
  mapkeys = flatten([
    for k, key in local.keys : {
      name   = key.name
      secret = key.value
    }
  ])
}

resource "aws_ssm_parameter" "put" {
  for_each = {
    for key in local.mapkeys : "${key.name}" => key
  }
  name  = each.value.name
  type  = "SecureString"
  value = each.value.secret
}
