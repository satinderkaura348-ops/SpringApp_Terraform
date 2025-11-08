terraform {
   backend "s3" {
    bucket         = "s3-for-noobs" 
    key            = "env/terraform.tfstate"
    region         = "ap-southeast-2"
    encrypt        = true
    use_lockfile = false
 }
 }