terraform {
   backend "s3" {
    bucket         = "s3-for-noobs-1" 
    key            = "env/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    use_lockfile = false
 }
 }