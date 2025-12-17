variable "ami_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "sg_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "instance_count" {
  type    = number
  default = 3
}

variable "azs" {
  type = list(string)
}

variable "fdb_version" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "fdb_cluster_file" {
  type = string
}

variable "env" {
  type    = string
  default = ""
}

variable "cluster_name" {
  type    = string
  default = ""
}

variable "datadog_api_key" {
  type      = string
  default   = ""
  sensitive = true
}
