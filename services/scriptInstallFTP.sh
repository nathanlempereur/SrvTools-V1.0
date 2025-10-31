#!/bin/bash

source config.sh
source fonction.sh

echo "
*************************************************************************************
*************************************************************************************
********************************Test de la config reseau sur www.google.fr***********
*************************************************************************************
*************************************************************************************
"
ping -c 3 www.google.fr > /dev/null

if [[ $? -eq 0 ]]; then
    echo -e "${valid}
*************************************************************************************
********************************Config reseau OK !***********************************
*************************************************************************************${blanc}
"
else
    echo -e "${erreur}
*************************************************************************************
********************************Erreur dans la config reseau*************************
*************************************************************************************${blanc}
"
    exit 1
fi



echo "
*************************************************************************************
*************************************************************************************
********************************Installation de Pure-ftpd****************************
*************************************************************************************
*************************************************************************************
"


apt update > /dev/null

apt install -y pure-ftpd

if ! id "ftp" &>/dev/null; then
    useradd -d /home/ftp -m -s /bin/false ftp
fi

read -p "Voulez-vous activer le mode anonyme ? (o/n) : " anonyme
while [ "$anonyme" != "o" ] && [ "$anonyme" != "n" ]; do
    echo "Saisie incorrecte."
    read -p "Voulez-vous activer le mode anonyme ? (o/n) : " anonyme
done
if [[ $anonyme == "o" ]]; then
	echo "no" > /etc/pure-ftpd/conf/NoAnonymous

	read -p "L'autoriser a uploader ? (o/n) : " upload
	while [ "$upload" != "o" ] && [ "$upload" != "n" ]; do
    	echo "Saisie incorrecte."
    	read -p "L'autoriser a uploader ? (o/n) : " upload
	done
	if [[ $upload == "n" ]]; then
		echo "yes" > /etc/pure-ftpd/conf/AnonymousCantUpload
	else
		echo "no" > /etc/pure-ftpd/conf/AnonymousCantUpload
	fi

	read -p "Activer la connexion anonyme seul ? (o/n) : " anonymeSeul
	while [ "$anonymeSeul" != "o" ] && [ "$anonymeSeul" != "n" ]; do
    	echo "Saisie incorrecte."
    	read -p "Activer la connexion anonyme seul ? (o/n) : " anonymeSeul
	done
	if [[ $anonymeSeul == "o" ]]; then
		echo "yes" > /etc/pure-ftpd/conf/AnonymousOnly
	else
		echo "no" > /etc/pure-ftpd/conf/AnonymousOnly
	fi
else
    echo "yes" > /etc/pure-ftpd/conf/NoAnonymous
fi

read -p "Restreindre l access au repertoire personnel de l'utilisateur ?  (o/n) : " zone
while [ "$zone" != "o" ] && [ "$zone" != "n" ]; do
    	echo "Saisie incorrecte."
    	read -p "Restreindre l access au répertoire personnel de l'utilisateur ?  (o/n) : " zone
done
if [[ $zone == "o" ]]; then
	echo "yes" > /etc/pure-ftpd/conf/ChrootEveryone
else
	echo "no" > /etc/pure-ftpd/conf/ChrootEveryone
fi

read -p "Combien de clients maximum connecter simultanément voulez-vous ? : " clientsNumber
echo $clientsNumber > /etc/pure-ftpd/conf/MaxClientsNumber


read -p "Combien de clients maximum par IP voulez-vous ? : " clientsIP
echo $clientsIP > /etc/pure-ftpd/conf/MaxClientsPerIP


read -p "Sauvegarder tous les fichiers déposés ? (o/n) : " keep
while [ "$keep" != "o" ] && [ "$keep" != "n" ]; do
    	echo "Saisie incorrecte."
    	read -p "Sauvegarder tout les fichiers déposés ? (o/n) : " keep
done
if [[ $keep == "o" ]]; then
	echo "yes" > /etc/pure-ftpd/conf/KeepAllFiles
else
	echo "no" > /etc/pure-ftpd/conf/KeepAllFiles
fi


read -p "Autoriser a renommer les fichiers ? (o/n) : " rename
while [ "$rename" != "o" ] && [ "$rename" != "n" ]; do
    	echo "Saisie incorrecte."
    	read -p "Autoriser a renomer les fichiers ? (o/n) : " rename
done
if [[ $rename == "n" ]]; then
	echo "yes" > /etc/pure-ftpd/conf/NoRename
else
	echo "no" > /etc/pure-ftpd/conf/NoRename
fi


systemctl restart pure-ftpd

if [[ $? -eq 0 ]]; then
    echo -e "${valid}
*************************************************************************************
*************************************************************************************
********************************Installation réussite********************************
*************************************************************************************
*************************************************************************************
*************************************************************************************
Restriction de zone de l'utilisateur -- : $(cat /etc/pure-ftpd/conf/ChrootEveryone)
Nombre de clients Max connecter ------- : $clientsNumber
Nombre de clients Max par IP ---------- : $clientsIP
Sauvegarde des fichier 	--------------- : $(cat /etc/pure-ftpd/conf/KeepAllFiles)
Bloquer le renomage des fichiers ------ : $(cat /etc/pure-ftpd/conf/NoRename)
Bloquer le mode anonyme --------------- : $(cat /etc/pure-ftpd/conf/NoAnonymous)
*************************************************************************************
*************************************************************************************${blanc}
"
else
    echo -e "${erreur}
*************************************************************************************
*************************************************************************************
********************************Erreur lors de l'installation************************
*************************************************************************************
*************************************************************************************${blanc}
"
fi

echo "[Appuyer sur entrer pour continuer]"
read