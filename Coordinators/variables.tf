variable "ami_id" {}
variable "subnet_ids" { type = list(string) }
variable "sg_id" {}
variable "instance_type" {}
variable "count" { type = number }
variable "azs" { type = list(string) }
variable "fdb_version" {}
variable "cluster_id" {}
variable "fdb_cluster_file" { type = string }

variable "datadog_api_key" {
  type    = string
  default = ""
}
