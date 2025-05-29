/*terraform {
  backend "s3" {
    bucket         = "terraform-state-file" # change this
    key            = "statefile/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}*/