#!/bin/bash

if [[ ! -f config.sh ]]; then
	bash install/install.sh
fi

if [[ $? -ne 0 ]]; then
	exit 0
fi

user=$(whoami)
if [[ $user != 'root' ]]; then
    echo "Vous devez être root pour continuer."
    exit 2
fi

#import des configs et fonctions
source config.sh
source fonction.sh


echo "Bienvenu dans :"
afficheTitre "SrvTools"
quitter=1
while [[ $quitter -ne 0 ]]
do
echo ""
afficheTitre "Menu principal"
echo ""
echo "Bienvenue $nom !"
echo "1) Installation de services"
echo "2) Installation de WebApps"
echo "3) Configuration du serveur"
echo "0) Quitter"
echo -e "Veuillez choisir une option :"
read choix
case $choix in 
	1 )
		bash services/service.sh
		;;
	2 )
		bash WebApp/WebApp.sh
		;;
	3 )
		bash configuration/configuration.sh
		;;
	0 )
		quitter=0
		afficheTitre "Au revoir !"
		;;
	* )
		echo "Erreur dans la saisie"
		;;
esac
done
