variable "cluster_name" {}
variable "alb_subnets" {
  type = list(string)
}
variable "service_subnets" {
  type = list(string)
}
variable "vpc_id" {}

variable "container_definitions" {
  type = list(object({
    name           = string
    container_port = number
    path           = string
    image          = string
  }))
}