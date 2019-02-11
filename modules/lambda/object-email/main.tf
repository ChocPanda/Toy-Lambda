data "archive_file" "get_zip" {
  type        = "zip"
  source_file = "${var.lambda_source_dir}/${var.lambda_source_file}"
  output_path = "${var.lambda_dist_dir}/${replace(var.lambda_source_file, ".js", ".zip")}"
}

data "aws_iam_policy_document" "lambda-assume-role-policy-doc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.app_name}-lambda-role-${terraform.workspace}"
  path               = "/system/"
  assume_role_policy = "${data.aws_iam_policy_document.lambda-assume-role-policy-doc.json}"

  tags = {
    workspace = "${terraform.workspace}"
    app       = "${var.app_name}"
    region    = "${var.aws_region}"
  }
}

data "aws_iam_policy_document" "lambda_ses_policy_doc" {
  statement = {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:*"]
  }

  statement = {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*"]
  }

  statement = {
    effect    = "Allow"
    actions   = ["ses:SendEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_ses_policy" {
  name        = "SES_Lambda_${terraform.workspace}_policy"
  path        = "/system/"
  description = "Lambda SES policy"

  policy = "${data.aws_iam_policy_document.lambda_ses_policy_doc.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_ses_policy_attachment" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_ses_policy.arn}"
}

resource "aws_lambda_function" "object-email-lambda" {
  filename         = "${data.archive_file.get_zip.output_path}"
  function_name    = "object-email-${var.aws_region}-${terraform.workspace}"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "index.handler"
  source_code_hash = "${base64sha256(file("./modules/lambda/object-email/src/index.js"))}"
  runtime          = "nodejs8.10"

  environment {
    variables {
      SOURCE_ADDR      = "${var.source_address}"
      DESTINATION_ADDR = "${jsonencode(var.destination_addresses)}"
      REPLY_ADDR       = "${jsonencode(var.reply_addresses)}"
    }
  }
}
