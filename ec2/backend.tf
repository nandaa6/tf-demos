terraform {
  backend "s3" {
    bucket         = "terraform-statefile-learnnine" # change this
    key            = "statefile/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-learnnine"
  }
}