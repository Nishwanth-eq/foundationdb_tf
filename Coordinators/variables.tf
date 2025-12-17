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

variable "env" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "datadog_api_key" {
  type      = string
  default   = ""
  sensitive = true
}
