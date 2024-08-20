######################
# Account and Region #
######################

variable "aws_account_id" {
  description = "Your Account ID"
  type        = string
}

variable "region" {
  description = "AWS Region where to run the project"
  type        = string
}


###########
# Buckets #
###########

variable "website_bucket" {
  description = "Static Website Bucket name"
  type        = string
}

variable "upload_bucket" {
  description = "Backend Bucket name"
  type        = string
}


###############
# Domain Name #
###############

variable "domain_name" {
  description = "Domain Name"
  type        = string
}


#############
# SNS Topic #
#############

variable "sns" {
  description = "SNS Topic Name"
  type = string
}

variable "sns_email" {
  description = "Email address for SNS"
}