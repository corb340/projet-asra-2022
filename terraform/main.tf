#fichier principal contenant tout ce qu'il faut pour configurer les instances (boot, network, ansible sync)

#initialisation du réseau
#resource "openstack_networking_network_v2" "reseau" {
#  name = "vrack"
#}

#initialisation sous-reseau
#resource "openstack_networking_subnet_v2" "sous_reseau" {
#  name = "sous_reseau"
#  network_id = "${openstack_networking_network_v2.reseau.id}"
#  cidr = "192.168.25.0/24"
#  ip_version = 4
#  enable_dhcp = "true"
#  no_gateway = "true"
#}

#resource 


#création d'une ressource de paire de clés SSH
resource "openstack_compute_keypair_v2" "test_keypair" {
  count      = length(var.region)
  provider   = openstack.ovh
  name       = "sshkey_${var.instance_name}"
  public_key = file("~/.ssh/id_rsa.pub")
  region     = element(var.region,count.index)
}

#création des instances
#celle du front end
resource "openstack_compute_instance_v2" "front_projet_terraform" {
  name        = "front_${var.instance_name}"
  provider    = openstack.ovh
  image_name  = var.image_name
  flavor_name = var.flavor_name
  region      = element(var.region,0)

  key_pair = openstack_compute_keypair_v2.test_keypair[0].name

  network {
    name       = "Ext-Net"
  }
}

#puis du backend
resource "openstack_compute_instance_v2" "backend_projet_terraform" {
  count       = var.backend_number_of_instances * length(var.region)
  name        = "backend_${var.instance_name}_${lower(substr(element(var.region,count.index),0,3))}_${count.index == 0 ? count.index+1 : ceil((count.index+1)/2)}"
  provider    = openstack.ovh
  image_name  = var.image_name
  flavor_name = var.flavor_name
  region      = element(var.region,count.index)

  key_pair = openstack_compute_keypair_v2.test_keypair[count.index%2].name

  network {
    name       = "Ext-Net"
  }
}
