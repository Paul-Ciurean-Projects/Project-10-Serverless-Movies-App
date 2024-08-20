##################
# Website bucket #
##################

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.website_bucket
}

resource "aws_s3_bucket_policy" "oac_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.my_distribution.arn
          }
        }
      }
    ]
  })
}


#################
# upload bucket #
#################

resource "aws_s3_bucket" "upload_bucket" {
  bucket = var.upload_bucket
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_upload_from_s3.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
