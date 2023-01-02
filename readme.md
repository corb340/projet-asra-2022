# Projet Final Administration Systèmes et Réseaux Avancé

Ce projet consiste à établir un wordpress haute disponibilité. Ce wordpress haute disponibilité est lui même établi par l'implémentation de scripts Terraform et Ansible.

Terraform est utilisé pour le déploiement d'instances cloud. Dans ce projet, la partie Terraform est composée de:
	- un fichier `providers.tf` qui référence les providers utilisés
	- un fichier `variables.tf` qui référence lui toutes les variables utilisées
	- un fichier de script principal, qu'on a nommé `main.tf`
	- un dossier template, contenant:
		- un template générique de l'inventaire automatique

A son tour, Ansible est utilisé pour déployer les configuration sur ces mêmes instances. Dans ce projet, la partie Ansible est composée de:
