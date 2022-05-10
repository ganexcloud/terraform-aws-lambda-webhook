module "codepipeline_notifications" {
  source               = "ganexcloud/codepipeline-notifications/aws"
  version              = "1.0.0"
  lambda_function_name = "codepipeline-notifications"
  sns_topic_name       = "codepipeline-notifications"
  webhook_url          = "https://api.squadcast.com/v2/incidents/api/xxxxxxxxxxxxxxxxxxxx"
  messenger            = "squadcast"
}

module "codebuild" {
  source  = "ganexcloud/codebuild/aws"
  version = "1.0.0"
  name    = "pipeline"
  codebuild_source = {
    type = "CODEPIPELINE"
  }
  codebuild_source_s3_bucket_name = module.codepipeline.bucket_name
  environment = {
    compute_type    = "BUILD_GENERAL1_SMALL"
    privileged_mode = true
    variables = [
      {
        name  = "AWS_REGION"
        value = "us-east-1"
      },
      {
        name  = "AWS_ACCOUNT_ID"
        value = "xxxxxxx"
      },
      {
        name  = "ECR_REPO_NAME"
        value = "frontend"
      },
      {
        name  = "DOCKER_IMAGE"
        value = "api"
      },
      {
        name  = "APP_ENV_FILE"
        value = "appsettings.Homolog.json"
      },
    ]
  }
}

module "codepipeline" {
  source                       = "ganexcloud/codepipeline/aws"
  version                      = "1.1.0"
  name                         = "pipeline"
  s3_bucket_name               = "codepipeline-pipeline"
  create_cloudwatch_event_rule = true
  cloudwatch_event_pattern     = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["s3.amazonaws.com"],
    "eventName": ["PutObject", "CompleteMultipartUpload", "CopyObject"],
    "requestParameters": {
      "bucketName": ["codepipeline-pipeline"],
      "key": ["source.zip"]
    }
  }
}
EOF
  stages = [
    {
      name = "Source"
      action = [{
        name     = "Source"
        category = "Source"
        owner    = "AWS"
        provider = "S3"
        version  = "1"
        configuration = {
          "S3Bucket"           = "codepipeline-pipeline"
          "S3ObjectKey"        = "source.zip"
          PollForSourceChanges = false
        }
        input_artifacts  = []
        output_artifacts = ["SourceArtifact"]
        run_order        = 1
      }]
    },
    {
      name = "Build"
      action = [{
        name             = "Build"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = ["BuildArtifact"]
        version          = "1"
        run_order        = 2
        configuration = {
          ProjectName = module.codebuild.name
        }
      }]
    }
  ]
  create_notification_rule = true
  notification_rule_target = [
    {
      address = module.codepipeline_notifications.sns_topic_arn
    }
  ]
}

module "lambda_function_lambda_webhook" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "3.2.0"
  function_name = "lambda-webhook"
  handler       = "index.handler"
  memory_size   = 512
  timeout       = 120
  runtime       = "provided"
  source_path   = "files/lambda-webhook/"
  layers        = ["arn:aws:lambda:us-east-1:744348701589:layer:bash:8"]
  attach_policy = true
  publish       = true

  policy = module.iam_policy_lambda_webhook.arn
  allowed_triggers = {
    APIGatewayWebhookPost = {
      service    = "apigateway"
      source_arn = "${module.lambda_webhook.execution_arn}/webhook/POST/"
    }
  }
}

module "iam_policy_lambda_webhook" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 2.0"
  name    = "lambda-lambda-webhook"
  policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "${module.codepipeline.bucket_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter"
      ],
      "Resource": [
        "arn:aws:ssm:us-east-1:xxxxxxxxxx:parameter/ssh-key"
      ]
    }
  ]
}
EOF
}

module "lambda_webhook" {
  source            = "../../"
  name              = "lambda-webhook"
  lambda_invoke_arn = module.lambda_function_lambda_webhook.lambda_function_invoke_arn
}
