variable "deployment_id" {
  description = "A name that will be prepended to all resources for current deployment"
}

variable "instance_count" {
  description = "The number of instances to spin up in the vmss"
  default = 2
}

variable "golden_image_name" {
  description = "The name of the golden image"
}

variable "golden_image_resource_group_name" {
  description = "The resource group of the golden image"
}

variable "subnet_id" {
  description = "The id for the subnet spun up by foundation pipeline"
}

variable "resource_group" {
  description = "The resource group to deploy the scaling set to. Managed by foundation pipeline"
}
