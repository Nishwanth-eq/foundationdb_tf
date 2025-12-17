variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones"
}

variable "fdb_cluster_file" {
  type        = string
  description = "FoundationDB cluster file content"
}

variable "datadog_api_key" {
  type        = string
  default     = ""
  description = "Datadog API key for monitoring"
}
