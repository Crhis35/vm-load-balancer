variable "resource_group" {
  description = "The name of the resource group"
  type = object({
    name     = string
    location = string
  })
}

variable "virtual_network_name" {
  description = "Name of the ip"
  default     = "virtual_network"
}
variable "subnet_name" {
  description = "Name of the subnet"
  default     = "vmss-subnet"
}
