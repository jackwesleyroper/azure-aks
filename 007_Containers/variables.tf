variable "config" {
  type        = map(any)
  description = "A map containing key value pairs of any type"
}

variable "containers_aks_max_node_count" {
  type        = number
  default     = 5
  description = "Used to scale the max number of AKS nodes"
}
