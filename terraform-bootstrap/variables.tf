variable "region" {
    type        = string
    description = "AWS region for the bootstrap resources"
    default     = "us-east-1"
}

variable "state_bucket_name" {
    type        = string
    description = "S3 bucket name for Terraform state"
    default     = "dashlab-terraform-state"
}

variable "lock_table_name" {
    type        = string
    description = "DynamoDB table name for Terraform state locks"
    default     = "dashlab-tf-lock"
}
