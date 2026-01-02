terraform {
  backend "s3" {
    bucket         = "manoj-terraform-remote-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
