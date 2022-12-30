#=================VARIABLE CONCERNANT LES INSTANCES (GENERALES)=================#  

#référencement des régions
variable "region" {
  type    = list
  default = ["GRA11","SBG5"]
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


#=================VARIABLE CONCERNANT LE RESEAU=================#

#variable nom de service pour le vRack
variable "service_name" {
  type    = string
}

#identifiant vrack
variable  "vlan_id" {
  type    = number
  default = 25
}

#adresse de départ dhcp
variable "vlan_dhcp_start" {
  type    = string
  default = "192.168.25.1"
}

#adresse de fin de plage dhcp
variable "vlan_dhcp_finish" {
  type    = string
  default = "192.168.25.100"
}

#adresse CIDR du réseau
variable "vlan_dhcp_network" {
  type    = string
  default = "192.168.25.0/24"
}
