variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "domain_name" {
  type        = string
  description = "Domain name of the application. e.g. 'alta-barra.com'"
}

variable "namespace" {
  type        = string
  description = "Namespace the resource belong to. e.g. 'webapp'"
}
