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
***************************** Récupération de Dotlcear ******************************
*************************************************************************************
*************************************************************************************
"


apt install -y wget zip > /dev/null 2>&1

wget https://nlempereur.ovh/dotclear.tar.gz
if [[ $? -ne 0 ]]; then
    echo -e "${erreur}
*************************************************************************************
***************************Erreur lors du téléchargement de Dotclear*****************
*************************************************************************************${blanc}"
    exit 1
fi

tar -xzf dotclear.tar.gz
rm dotclear.tar.gz
mv dotclear /var/www/

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
	DocumentRoot /var/www/dotclear
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
	
	<Directory /var/www/dotclear>
		Options Indexes FollowSymLinks
		Require all granted
	</Directory>
</VirtualHost>" > /etc/apache2/sites-available/dotclear.conf

a2ensite dotclear.conf > /dev/null 
chown -R www-data:www-data /var/www/dotclear


echo "
*************************************************************************************
****************************** Installation de la BDD *******************************
*************************************************************************************
"

read -p "Nom pour l'utilisateur de la base de données : " nom
read -s -p "Mot de passe pour cet utilisateur : " Mdp
echo ""
mysql -u root -e "
CREATE DATABASE dotclear;
GRANT ALL PRIVILEGES ON dotclear.* TO '$nom'@'localhost' IDENTIFIED BY '$Mdp';
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
Chemin web  : ${valid}/var/www/dotclear${blanc}
Nom de la BDD : ${valid}dotclear${blanc}
Utilisateur  : ${valid}$nom${blanc}
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
