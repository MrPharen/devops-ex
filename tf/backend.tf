terraform {
  backend "s3" {
    bucket = "tf-state"
    key    = "tf"
    region = "us-east-1"
  }
}