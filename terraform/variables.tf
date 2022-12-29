#référencement des régions
variable "region" {
#  type    = list
#  default = ["GRA11","SBG5"]
  type = string
  default = "GRA11"
}

#nom de l'instance selon eductive25
variable "instance_name" {
  type    = string
  default = "eductive25"
}

#image utilisé
variable "image_name" {
  type    = string
  default = "Debian 11"
}

#flavor
variable "flavor_name" {

  type    = string
  default = "s1-2"
}

#nombre d'instances back
variable "backend_number_of_instances" {
  type    = number
  default = 1
}

