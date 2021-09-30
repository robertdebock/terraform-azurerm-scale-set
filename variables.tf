variable "name" {
  type    = string
  default = "default"
}

variable "instances" {
  description = "The number of machines to spin up in the scale group."
  type    = number
  default = 1
}

variable "maximum_instances" {
  description = "The maximum number of machines to spin up in the scale group."
  type        = number
  default    = 10
}
