provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "instance1" {
  ami           = "ami-08b5b3a93ed654d19"
  instance_type = "${var.instance_type}"
  tags = {
    name = "${var.name}"
  }
}

# resource "aws_s3_bucket" "s3_bucket" {
#   bucket = "terraform-statefile-learnnine" # change this
# }

# resource "aws_dynamodb_table" "terraform_lock" {
#   name           = "terraform-lock-learnnine"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
