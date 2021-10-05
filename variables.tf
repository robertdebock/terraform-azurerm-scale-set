variable "name" {
  type    = string
  default = "default"
}

variable "instances" {
  description = "The number of machines to spin up in the scale group."
  type    = number
  default = 1
  validation {
    condition     = var.instances > 0
    error_message = "The minimum for \"instances\" is 1."
  }
}

variable "minimum_instances" {
  description = "The minimum number of machines to spin up in the scale group."
  type        = number
  default     = 1
  validation {
    condition     = var.minimum_instances > 0
    error_message = "The minimum for \"minimum_instances\" is 1."
  }
}

variable "maximum_instances" {
  description = "The maximum number of machines to spin up in the scale group."
  type        = number
  default     = 10
  validation {
    condition     = var.maximum_instances > 0
    error_message = "The minimum for \"maximum_instances\" is 1."
  }
}

variable "custom_emails" {
  description = "A list of email addresses to notify of scale-set changes."
  type        = list
  default     = ["robert@meinit.nl"]
}
