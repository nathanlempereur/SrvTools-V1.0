#!/bin/bash

#import des configs et fonctions
source config.sh
source fonction.sh


afficheTitre "Configuration serveur"
quitter=1
while [[ $quitter -ne 0 ]]
do
echo ""
echo "1) Configuration réseau"
echo "2) Backup d'un dossier"
echo "0) Quitter"
echo -e "Veuillez choisir une option :"
read choix
case $choix in 
	1 )
		bash configuration/ConfReseau.sh
		;;
	2 )
		bash configuration/Backup.sh
		;;
	0 )
		quitter=0
		;;
	* )
		echo "Erreur dans la saisie"
		;;
esac
done
