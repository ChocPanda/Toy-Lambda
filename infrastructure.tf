provider "aws" {
  profile = "cp-terraform"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket         = "chocpanda.eu-west-1.terraform-state"
    key            = "email-lambda/terraform.tfstate"
    dynamodb_table = "chocpanda-terraform-locks"
    profile        = "cp-terraform"
    region         = "eu-west-1"
  }
}

variable "aws_region" {
  default = "eu-west-1" // Ireland
}

variable "app_name" {
  default = "email-lambda"
}

resource "aws_s3_bucket" "drop_bucket" {
  bucket = "sl-${var.app_name}-s3-${var.aws_region}-${terraform.workspace}-drop"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    workspace = "${terraform.workspace}"
    app_name  = "${var.app_name}"
    region    = "${var.aws_region}"
  }
}

module "object-email" {
  source          = "modules/lambda/object-email"
  app_name        = "${var.app_name}"
  aws_region      = "${var.aws_region}"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${module.object-email.lambda_arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.drop_bucket.arn}"
}

resource "aws_s3_bucket_notification" "drop_bucket_notification" {
  bucket = "${aws_s3_bucket.drop_bucket.id}"

  lambda_function {
    lambda_function_arn = "${module.object-email.lambda_arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}
