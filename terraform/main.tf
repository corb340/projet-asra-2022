#fichier principal contenant tout ce qu'il faut pour configurer les instances (boot, network, ansible sync)

#====================VRACK====================#
 
#création du réseau privé
resource "ovh_cloud_project_network_private" "private_network" {
  service_name = var.service_name 
  name         = "private_network_${var.instance_name}"
  regions       = var.region           
  provider     = ovh.ovh
  vlan_id      = var.vlan_id
#  depends_on   = [ovh_vrack_cloudproject.vcp]
}
 
#creation du sous reseau
resource "ovh_cloud_project_network_private_subnet" "subnetwork" {
  count        = length(var.region)
  network_id   = ovh_cloud_project_network_private.private_network.id
  service_name = var.service_name
  region       = element(var.region,count.index) 
  network      = var.vlan_dhcp_network
  start        = var.vlan_dhcp_start
  end          = var.vlan_dhcp_finish  
  dhcp         = true
  provider     = ovh.ovh
  no_gateway   = true
}

#====================INSTANCES ET CLES SSH====================#

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
  #interface réseau public
  network {
    name       = "Ext-Net"
  }
  #interface réseau privé
  network {
    name      = ovh_cloud_project_network_private.private_network.name
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnetwork]
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
  #iface réseau public
  network {
    name      = "Ext-Net"
  }
  #iface réseau privé
  network {
    name      = ovh_cloud_project_network_private.private_network.name
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnetwork]
}
