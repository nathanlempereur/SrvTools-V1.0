#!/bin/bash 

source config.sh
source fonction.sh

echo "
*************************************************************************************
*************************************************************************************
****************************** Installation de Apache2 Server ***********************
*************************************************************************************
*************************************************************************************
"

WebApp/./scriptInstallApache2.sh

if [[ $? -ne 0 ]]; then
    exit 1
fi

echo "
*************************************************************************************
*************************************************************************************
********************************Recuperation du Dolibarr*****************************
*************************************************************************************
*************************************************************************************
"
apt install -y wget zip > /dev/null 2>&1

wget https://nlempereur.ovh/dolibarr.zip
if [[ $? -ne 0 ]]; then
    echo -e "${erreur}
*************************************************************************************
***************************Erreur lors du téléchargement de Dolibarr*****************
*************************************************************************************${blanc}"
    exit 1
fi


unzip dolibarr.zip

rm dolibarr.zip

rm -rf /var/www/dolibarr > /dev/null 2>&1
mv dolibarr* /var/www/dolibarr

if [[ $? -eq 0 ]]; then
    echo -e "${valid}
*************************************************************************************
*********************** Extraction vers /var/www/ réussie ! **************************
*************************************************************************************${blanc}
"
else
    echo -e "${erreur}
*************************************************************************************
***************************** Erreur dans l'extraction *******************************
*************************************************************************************${blanc}
"
    exit 1
fi


echo "
*************************************************************************************
*************************************************************************************
********************************Configuration du site********************************
*************************************************************************************
*************************************************************************************
"

a2dissite 000-default.conf > /dev/null 2>&1

read -p "Nom de domaine pour ce site (o/n) ? : " repdomaine
while [ "$repdomaine" != "o" ] && [ "$repdomaine" != "n" ]; do
    echo "Saisie incorrecte."
    read -p "Nom de domaine pour ce site (o/n) ? : " repdomaine
done
if [[ $repdomaine == "o" ]]; then
    read -p "Donnez le nom de domaine pour ce site : " domaine
    a="ServerName $domaine"
else
    a=""
fi
echo "
<VirtualHost *:80>
    $a
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/dolibarr/htdocs
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
	
	<Directory /var/www/dolibarr>
		Options Indexes FollowSymLinks
		Require all granted
	</Directory>
</VirtualHost>" > /etc/apache2/sites-available/dolibarr.conf

a2ensite dolibarr.conf
chown -R www-data:www-data /var/www/dolibarr

echo "
*************************************************************************************
****************************** Installation de la BDD *******************************
*************************************************************************************
"

read -p "Nom pour l'utilisateur de la base de données : " nom
read -s -p "Mot de passe pour cet utilisateur : " Mdp
echo ""

mysql -u root -e "
CREATE DATABASE dolibarr;
GRANT ALL PRIVILEGES ON dolibarr.* TO '$nom'@'localhost' IDENTIFIED BY '$Mdp';
FLUSH PRIVILEGES;
"

systemctl restart apache2

if [[ $? -eq 0 ]]; then
    echo -e "${valid}
*************************************************************************************
*************************************************************************************
***************************** Installation réussie ! *********************************
*************************************************************************************
*************************************************************************************${blanc}

******************************************************
Connectez-vous à cette IP sur le poste client : ${valid}$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1)${blanc}
******************************************************

**********************************************************
Le chemin de votre page web est /var/www/dolibarr ********
**********************************************************
Nom de la BDD   : ${valid}dolibarr${blanc}
Nom du clients  : ${valid}$nom${blanc}  
MDP             : ${valid}$Mdp${blanc}
**********************************************************
"
else
    echo -e "${erreur}
*************************************************************************************
*************************************************************************************
*************************** Erreur lors de l'installation ***************************
*************************************************************************************
*************************************************************************************${blanc}
"
    exit 1
fi

echo "[Appuyez sur Entrée pour continuer]"
read
