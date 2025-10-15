variable "clustername" {}
variable "env" {}
variable "clustersg" {
  description = "this is the name of securitygroup"
  type        = string
}

variable "vpcname" {
  type        = string
}

variable "pubsub01" {
  type        = string
}
variable "pubsub02" {
  type        = string
}
#variable "pri01" {
#  type        = string
#}
#variable "pri02" {
#  type        = string
#}

variable "block1" {
  type        = string
}
variable "block2" {
  type        = string
}
variable "block3" {
  type        = string
}
variable "block4" {
  type        = string
<<<<<<< HEAD
=======
  default     = "1.31"
>>>>>>> 57eb1e1890413234d37fc5ab60043ef4acc16846
}


variable "block5" {
  type        = string
}
variable "block6" {
  type        = string
}