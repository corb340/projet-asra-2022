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
	- un dossier `ifconfig.io` qui est le dossier docker de l'application web ifconfig.io

## Le dossier terraform

Celui-ci est composé de trois fichier et d'un dossier templates.

### Le fichier providers.tf

Ce fichier est composé essentiellement de deux parties:
1. Une partie vRack
2. Une partie instances et clés SSH.

#### Le vRack

Un **vRack** est un terme concept utilisé par OVH pour parler **d'un VLAN qui connecte diverses instances**. 

