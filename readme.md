# Projet Final Administration Systèmes et Réseaux Avancé

Ce projet consiste à établir un wordpress haute disponibilité. Ce wordpress haute disponibilité est lui même établi par l'implémentation de scripts Terraform et Ansible.


Terraform est utilisé pour le **déploiement d'instances cloud**. Dans ce projet, la partie Terraform est composée de:

- un fichier providers.tf qui référence les providers utilisés
- un fichier variables.tf qui référence lui toutes les variables utilisées
- un fichier de script principal, qu'on a nommé `main.tf`
- un dossier template, contenant:
	- un template générique de l'inventaire automatique


A son tour, Ansible est utilisé pour déployer les configuration sur ces mêmes instances. Dans ce projet, la partie Ansible est composée de:

- un fichier `playbooks.yml`, qui contient donc le **playbook**, suite d'instructions servant à configurer le projet.
- un dossier *template* contenant:
	- un fichier `default.j2` qui contient le template écrit en jinja (j2) de la configuration serveur de Nginx
	- un fichier `haproxy.cfg.j2` qui contient le template de la configuration de HaProxy
	- un fichier `index.html.j2` qui contient le template de la page web chaton, tournant sous Nginx
	- un fichier `exports.j2` qui contient le template du fichier configuration du serveur NFS
	- un fichier `docker-compose.yml.j2` qui contient le template du fichier configuration du docker.
	- un dossier `ifconfig.io` qui est le dossier docker de l'application web ifconfig.io

## Le dossier Terraform

Celui-ci est composé de trois fichier et d'un dossier templates.

### Le fichier providers.tf

Le fichier providers.tf est un fichier qui contient:

1. Un bloc terraform, lui-même contenu par:
	- la version requise
	- les providers requis, qui sont OpenStack, OVH et un provider local permettant de créer dynamiquement l'inventaire ansible.

2. Deux blocs providers, qui définissent les modalités d'accès a ces providers. Ces providers sont:
	- OpenStack
	- OVH

Ce fichier est utilisé pour la configuration terraform.

### Le fichier variables.tf

Ce fichier sert à référencer les différentes variables utilisées dans l'implémentation de l'infrastructure.

#### Les variables générales (concernant les instances)

Ces variables sont:

- la variable `region`, qui est la liste des régions utilisées (ici `GRA11` et `SBG5`)
- la variable `instance_name`, qui est le nom des instances (`eductive25`)
- la variable `image_name`, le nom de l'image utilisée (ici `Debian 11` pour installer une instance Debian version 11)
- la variable `flavor_name`, qui est le flavor de chaque instance compute (`s1-2`)
- enfin la variable `backend_number_of_instances`, qui est le nombre d'instances backend par région

Nous n'avons pas le nombre d'instances par région backend des instances front car elle est fixe.

#### Variables concernant le réseau (vRack)

Ces variables sont:

- la variable `service_name`, qui est une chaine de caractères. Ici elle est vide car elle tire son contenu de la variable d'environnement.
- la variable `vlan_id`, qui est l'identifiant du vRack. Ici qui correspond à notre numéro eductive, c'est-à-dire `25`
- la variable `vlan_dhcp_start`, qui est le départ de notre plage d'adressage sous-réseau (`192.168.25.1`)
- la variable `vlan_dhcp_finish`, qui est la fin de notre plage d'adressage sous-réseau (`192.168.25.200`)
- la variable `vlan_dhcp_network`, qui est l'adresse réseau du vRack (`192.168.25.0/24`)

### Le fichier main.tf

Ce fichier est composé essentiellement de deux parties:
1. Une partie vRack
2. Une partie instances et clés SSH.

#### Le vRack

Un **vRack** est un terme concept utilisé par OVH pour parler **d'un VLAN qui connecte diverses instances**. 

Pour faire un vRack, cela se fait en 4 étapes:

1. Création du projet cloud (`ovh_cloud_project`), déjà préalablement fait, donc pas implémenté dans `main.tf`. Il est composé d'un attribut essentiel à sa création, `service_name`, qui définit l'identifiant à utiliser sur l'infrastructure OVH
2. Création du réseau privé avec `ovh_cloud_project_network_private`. Cette partie est composé de plusieurs attributs, dont:
	- le nom ce ce réseau privé
	- les régions affectées à ce réseau
	- le provider utilisé (ici OVH)
	- identifiant du réseau virtuel (vLAN)
3. Création d'un sous-réseau par région (une pour **Gravelines**, une autre pour **Strasbourg**), avec `ovh_cloud_project_network_private_subnet`. Cette partie est composée de plusieurs attributs, dont:
	- identifiant du réseau (pour forcément affecter le sous-réseau au réseau)
	- la région affectée
	- l'adresse de départ affecté
	- l'addresse d'arrivée affectée
	- si il est composé d'une passerelle
	
#### Les clés SSH

Cette partie est composé que d'un seul bloc. En effet, il suffit d'avoir une clé SSH par région afin (y compris si c'est la même) afin de respecter la nomenclature par régions. Afin que l'on puisse générer ces clés ssh, il faut:
	- un argument `count` qui est égal au nombres de régions
	- le provider attribué
	- le nom, qui est composé de "ssh" suivi du nom de l'instance et de la région
	- d'un lien fichier vers la clé SSH
	- et de la région affectée (en s'aidant de count)

#### Les instances

Cette partie, relativement longue, représente plus de la moitié du fichier. Elle ne juge que par un seul type d'instance, qui est `openstack_compute_instance_v2`. Elle se sépare en deux parties:

1. Une sous-partie frontend, qui servira pour HAProxy et le serveurs NFS. Cette partie est composée:
	- d'une instance qui s'appelle `front`
	- que d'une seule région, car on a besoin que d'un seul front-end
	- d'un nom, dont la nomenclature est "front" suivi du nom de l'instance
	- du nom de l'image
	- de son "flavor"
	- de sa clé SSH
	- et de ses deux interfaces réseaux (une publique pour une adresse publique et une privée pour une adresse privée)
	- cette partie dépend de même du sous-réseau de Gravelines (avec `depends_on`)

2. Une deuxième sous-partie, qui sera le backbone de notre infrastructure. Les back-ends, qui sont eux répartis sur Gravelines et Strasbourg. Cette ressource, qu'on a appelé respectivement pour Gravelines et Strasbourg `backend_gra` et `backend_sbg` est implémenté de la même manière que la partie front. Seul chose qui change est le nom, qui est sous la forme "backend_" suivi du nom de l'instance, puis de la région ainsi que de son index dans le count.

#### La base de données OVH

Cette partie est dédié à la création d'un instance de base de données hébergé chez OVH. Elle est composé de plusieurs ressources:

1. Une ressource de type `ovh_cloud_project_database` appelé db_eductive25, qui est composé:
	- un moteur de base de données. On a donc pris `mysql`
	- d'un flavor
	- nous n'avons pas implémenté le service_name ni l'id, car elles sont toutes les deux égales et prennent la valeur de variables initiés par l'initialisation du projet cloud.
	
2. Une ressource de type `ovh_cloud_project_database_user` appelé `eductive25`, qui est composé essentiellement:
	- de son nom `eductive25`
	- du cluster id, identifiant de `db_eductive25`

3. Une ressource de type `ovh_cloud_project_database_database` appelé `database`, qui est composé essentiellement:
	- de son nom `wordpress_data`
	- de son cluster id
	
4. Deux ressources de type `ovh_cloud_project_database_ip_restriction` appelé `database`, qui est composé essentiellement:
	- d'un attribut count égal aux nombre d'instances backend
	- et d'une addresse ip, rentré dynamiquement selon les instances backend implémentées précédemment. Cet attribut `ip` fonctionne de la manière d'un whitelist, que l'on doit rentrer sous forme de chaîne de caractères (pas de liste, donc pas de mélange de régions)
	- nous avons donc deux instances de `ovh_cloud_project_database_ip_restriction`:
		- une pour Gravelines
		- une autre pour Strabourg

#### Relation avec la partie Ansible

Cette partie est la dernière du fichier `main.tf`. Il s'agit en effet d'un seule ressource de type `local_file` appelé `inventory`. Cette ressource, qui servira a créer dynamiquement l'inventaire ansible à l'aide du fichier terraform, est composé de:
	- un nom de fichier avec son chemin relatif vers le répertoire choisi
	- son contenu, en utilisant la fonction `templatefile` qui pointe vers le fichier template
	- ainsi que les instances mis en attribut dans une boucle générique, inclu dans la fonction
	
## Le dossier Ansible

Ce dossier, comporte énormément de fichiers. Ces fichiers sont séparés en deux types:

1. Les templates, dans un fichier `templates`
2. Le playbook, appelé `playbook.yml`, qui comporte la plupart du reste des fonctionnalités.

### Le dossier template

Ce dossier comporte tous les templates des différentes configurations. Il est composé:

- D'un dossier `ifconfig.io`, qui est juste le repo de l'application `ifconfig.io`
- D'une série de fichiers, templatisé sous format jinja (`.j2`)

#### Le dossier ifconfig.io

Ce repo github sert à récupérer son adresse ip. C'est une application Docker composé d'une multitude de fichiers utile au fonctionnement du site, ainsi que d'un `docker-compose.yml` et d'un `Dockerfile`.

#### Le fichier default.j2

Ce fichier est un fichier destiné au serveur web `nginx`, qui sera en backend. C'est un fichier à poser à l'emplacement `/etc/nginx/sites-available/`, et qui consiste à dire au serveur quoi faire. A savoir:
- `listen`: écouter sur l'IP publique de notre instance compute sur le port 80 par défaut
- `root`: à rediriger la racine de ce serveur vers `/var/www/html/`
- `index`: à indiquer quelle est la page d'accueil par défaut, dans un ordre de priorité:
	- d'abord `index.html`
	- ensuite `index.htm`
	- puis enfin `index.nginx-debian.html`
- `location`: sert à dire s'il y a une redirection à faire ou non
- `proxy_set_header`: sert à "forward" les requêtes effectuées sur le front.

#### Le fichier docker-compose.yml.j2

Ce fichier est le fichier template docker-compose du Wordpress. Ce fichier est composé de la version, d'un service wp composé lui-même d'une image wordpress de dernière version, d'une redirection de port (port 8000 de la machine redirigé vers le port 80 du container docker), d'un volume servant à mapper sur le serveur NFS, puis d'une liste de variables utilisés par wordpress pour se connecter à la base de données distante, en se servant des valeurs passées en inventaire par terraform (à l'aide du template).

#### Le fichier exports.j2

Ce fichier est le fichier servant à configurer le serveur NFS (qui est l'instance front).

#### Le fichier haproxy.cfg.j2

Ce fichier est le fichier configuration principal du reverse proxy `haproxy`. En effet, dans ce fichier bien rempli, il y a plusieurs choses intéressantes:

- Une configuration globale, recommandée pour n'importe quelle utilisation de ce proxy
- Une configuration par défaut, pour les mêmes raison que citées ci-dessus
- Une configuration afin d'afficher les statistiques de l'infrastructure (notion Actif/Backup implémentée, si elle est fonctionelle, quel serveur est down...)
- des interfaces d'écoute frontend (qui écoute donc sur l'IP publique de communications venant depuis internet). On en compte trois:
	1. Une première interface, servant à écouter sur le port 80, et donc si communication entrante le renvoie vers la partie backend du serveur chaton (Nginx)
	2. Une deuxième interface, servant à écouter sur le port 81, et à rediriger vers le backend du docker ifconfig.io
	3. Une troisième interface, servant à écouter sur le port 82, et à rediriger vers le backend du docker wordpress
- des interfaces d'écoute backend (après être redirigé par le front-end). Les redirection selons les régions sont:
	- Active pour `GRA11`
	- Backup pour `SBG5`
	- Voici sa composition:
		1. Une première interface backend, qui redirige ce qu'il a reçu du frontend vers les serveurs backend sur le port 80 (Serveur chaton)
		2. Une deuxième interface backend, qui redirige ce qu'il a reçu du frontend vers les serveurs backend sur le port 81 (Serveur ifconfig.io)
		3. Une troisième interface backend, qui redirige ce qu'il a reçu du frontend vers les serveurs backend sur le port 82 (Serveur wordpress)
	- Tous ces serveurs sont "forwardés"

#### Le fichier index.html.j2

Ce template est tout simplement le fichier template de la page web du serveur chaton.

### Le fichier playbook.yml

