provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "mitesh-state-file-bucket-aws"

  versioning {
   enabled = true 
  }

  tags = {
   Name = "Mario_bucket"
  }
}

resource "aws_dynamodb_table" "lock_table" {
  name = "tfstate-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
   name = "LockID"
   type = "S"
  }

  tags = {
   Name = "Terraform Lock Table"
  }
}


