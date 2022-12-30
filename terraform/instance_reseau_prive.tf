#ce fichier comporte la création des instances de réseau privé pour le vRack d'OVH

#association du cloud project au vrack
resource "ovh_vrack_cloudproject" "vcp" {
  service_name = var.service_name
  project_id = var.project_id
}

#création du réseau privé
resource "ovh_cloud_project_network_private" "reseau_prive" {
  service_name = var.service_name
  name         = "Reseau_Projet"
  region       = element(var.region,0)
  provider     = ovh.ovh
  vlan_id      = 25
  depends_on = [ovh_vrack_cloudproject.vcp]
}

#creation du sous reseau
resource "ovh_cloud_project_network_private_subnet" "sous_reseau" {
  network_id = ovh_cloud_project_network_private.reseau_prive.id
  service_name = var.service_name
  region = element(var.region,0)
  network = "192.168.25.0/24"
  start = "192.168.25.2"
  end = "192.168.25.5"
  dhcp = false
  provider = ovh.ovh
  no_gateway = true
}

