provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "instance1" {
  ami           = "ami-08b5b3a93ed654d19"
  instance_type = "t2.micro"
  tags = {
    name = "sample2-terraform-instance-branch2"
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  region = "eu-central-1"
  bucket = "terraform-statefile" # change this
}

resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
