terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "bucket_name" {
   description = "Name of the bucket to create"
   default = "roger-bucket-0"
}

variable "bucket_acl" {
   description = "ACL for S3 bucket: private, public-read, public-read-write, etc"
   default = "private"
}

variable "ip_addresses" {
  description = "list of prohibited IP address"
  default = ["1.1.1.1"]
}

variable "s3_vpce_id" {
  description = "S3 VPC endpoint"
  default = ""
}

variable "shared_s3_vpce_id" {
  description = "Shared S3 VPC endpoint"
  default = ""
}

resource "aws_kms_key" "my_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "bucket_0" {
  bucket = var.bucket_name
  acl    = var.bucket_acl

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"PublicRead",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject","s3:GetObjectVersion"],
      "Resource":["arn:aws:s3:::*"]
    }
  ]
}
POLICY

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.my_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

}

resource "aws_s3_bucket" "bucket_1" {
  bucket = "roger-bucket-1"
  acl    = var.bucket_acl

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.my_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

}

resource "aws_s3_bucket" "bucket_2" {
  bucket = "roger-bucket-2"
  acl    = var.bucket_acl

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.my_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

}

resource "aws_s3_bucket_policy" "bucket_policy_1" {
  bucket = aws_s3_bucket.bucket_1.id
  policy = data.aws_iam_policy_document.example.json
}

resource "aws_s3_bucket_policy" "bucket_policy_2" {
  bucket = aws_s3_bucket.bucket_2.id
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"PublicRead",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject","s3:GetObjectVersion"],
      "Resource":["arn:aws:s3:::*"]
    }
  ]
}
POLICY
}

data "aws_iam_policy_document" "example" {
  statement {
    sid = "Deny HTTP for bucket level operations"
    effect = "Deny"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bucket_1.id}",
    ]
    condition {
      test = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false",
      ]
    }
  }

  statement {
    sid = "Deny HTTP for object operations"
    effect = "Deny"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bucket_1.id}",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false",
      ]
    }
  }

  statement {
    sid = "Deny bucket access not through vpce"
    effect = "Deny"
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bucket_1.id}",
    ]
    condition {
      test     = "NotIpAddress"
      variable = "aws:SourceIp"
      values = var.ip_addresses
    }
    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"
      values = [
        "vpce-111111",
        var.s3_vpce_id,
        var.shared_s3_vpce_id
      ]
    }
  }

  statement {
    sid = "Deny object access not through vpce"
    effect = "Deny"
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bucket_1.id}",
    ]
    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"
      values = [
        "vpce-111111111111111111",
        var.s3_vpce_id,
        var.shared_s3_vpce_id
      ]
    }
  }
}

