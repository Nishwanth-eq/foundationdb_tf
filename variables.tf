variable "aws_region" { default = "us-east-1" }
variable "cluster_id" { default = "fdb-prod-cluster" }
variable "fdb_version" { default = "7.4.5" }
variable "vpc_cidr"  { default = "10.0.0.0/16" }
variable "azs"       { default = ["us-east-1a","us-east-1b","us-east-1c"] }

variable "datadog_api_key" {
  type        = string
  default     = ""
  description = "Datadog API key"
}
