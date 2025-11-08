terraform {
    backend "s3" {
        bucket = "s3-for-noobs"
        key = "infra.tfstate"
        region = "ap-southeast-2"
        use_lockfile = false
    }
}