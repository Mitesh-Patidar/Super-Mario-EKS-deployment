terraform {
  backend "s3" {
    bucket = "mitesh-state-file-bucket-aws"
    key = "eks/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "tfstate-lock-table"
    encrypt = true
  }
}
