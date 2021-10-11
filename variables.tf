variable "name" {
  description = "A name to use for most resources."
  default     = "default"
}

variable "location" {
  description = "The location where to deploy the firewall."
  default     = "West Europe"
}

variable "address_space" {
  description = "A list of network addresses."
  default     = ["10.0.0.0/16"]
}

variable "address_prefix" {
  description = "A list of addresse prefixes."
  default     = ["10.0.1.0/24"]
}
