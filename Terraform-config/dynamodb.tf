##################
# DynamoDB Table #
##################

resource "aws_dynamodb_table" "movies_table" {
  name           = "Movies"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "movies"

  attribute {
    name = "movies"
    type = "S"
  }
}