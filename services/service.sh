#!/bin/bash

#import des configs et fonctions
source config.sh
source fonction.sh


afficheTitre "Services"
quitter=1
while [[ $quitter -ne 0 ]]
do
echo ""
echo "1) Installation SSH"
echo "2) Installation FTP réel"
echo "3) Installation FTP virtuel"
echo "4) Installation Apache2 simple"
echo "5) Installation Fail2Ban"
echo "6) Installation partage SMB"
echo "0) Quitter"
echo -e "Veuillez choisir une option :"
read choix
case $choix in 
	1 )
		bash services/scriptInstallSSH.sh
		;;
	2 )
		bash services/scriptInstallFTP.sh
		;;
	3 )
		bash services/FTPvirtuel/scriptInstallFTPvirtuel.sh
		;;
	4 )
		bash services/scriptInstallApache2.sh
		;;
	5 )
		bash services/scriptInstallFail2ban.sh
		;;
	6 )
		bash services/scriptInstallSamba.sh
		;;
	0 )
		quitter=0
		;;
	* )
		echo "Erreur dans la saisie"
		;;
esac
done
