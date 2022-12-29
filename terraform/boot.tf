#création d'une ressource e paire de clés SSH
resource "openstack_compute_keypair_v2" "test_keypair" {
  count      = 
  provider   = openstack.ovh
  name       = "sshkey_${var.instance_name}"
  public_key = file("~/.ssh/id_rsa.pub")
}

#création des instances
resource "openstack_compute_instance_v2" "front_projet_terraform" {
  name        = "front_${var.instance_name}
  provider    = openstack.ovh
  image_name  = var.image_name
  flavor_name = var.flavor_name
  region      = element(var.region,0)

  key_pair = openstack_compute_keypair_v2.test_keypair.name

  network {
    name       = "Ext-Net"
  }
}

resource "openstack_compute_instance_v2" "backend_projet_terraform" {
  name        = var.instance_name
  provider    = openstack.ovh
  image_name  = var.image_name
  flavor_name = var.flavor_name
  region      = element(var.region,index

  key_pair = openstack_compute_keypair_v2.test_keypair.name

  network {
    name       = "Ext-Net"
  }
}
