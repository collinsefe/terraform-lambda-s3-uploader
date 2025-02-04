terraform {
  backend "s3" {
    bucket = "supandoprojects-terraformstate-710271940286"
    key    = "lambda/infra.tfstate"
    region = "eu-west-2"
  }
}
