#!/bin/bash

#import des configs et fonctions
source config.sh
source fonction.sh


afficheTitre "WebApp"
quitter=1
while [[ $quitter -ne 0 ]]
do
echo ""
echo "1) Installation Wordpress"
echo "2) Installation MediaWiki"
echo "3) Installation GLPI"
echo "4) Installation Dotclear"
echo "5) Installation Docuwiki"
echo "6) Installation Dolibarr"
echo "0) Quitter"
echo -e "Veuillez choisir une option :"
read choix
case $choix in 
	1 )
		bash WebApp/scriptInstallWordPress.sh
		;;
	2 )
		bash WebApp/scriptInstallMediaWiki.sh
		;;
	3 )
		bash WebApp/scriptInstallGlpi.sh
		;;
	4 )
		bash WebApp/scriptInstallDotclear.sh
		;;
	5 )
		bash WebApp/scriptInstallDocuwiki.sh
		;;
	6 )
		bash WebApp/scriptInstallDolibarr.sh
		;;
	0 )
		quitter=0
		;;
	* )
		echo "Erreur dans la saisie"
		;;
esac
done
