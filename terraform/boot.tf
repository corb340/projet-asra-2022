#création d'une ressource e paire de clés SSH
#resource "openstack_compute_keypair_v2" "test_keypair" {
#  provider   = openstack.ovh
#  name       = "sshkey_${var.instance_name}"
#  public_key = file("~/.ssh/id_rsa.pub")
#}

#création des instances
resource "openstack_compute_instance_v2" "projet_terraform" {
  name        = var.instance_name
  provider    = openstack.ovh
  image_name  = var.image_name
  flavor_name = var.flavor_name
  region      = var.region

#  key_pair = openstack_compute_keypair_v2.test_keypair.name

  network {
    name       = "Ext-Net"
  }
}
