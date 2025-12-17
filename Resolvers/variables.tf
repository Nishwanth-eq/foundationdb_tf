variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "fdb_cluster_file" {
  type = string
}

variable "datadog_api_key" {
  type      = string
  default   = ""
  sensitive = true
}
