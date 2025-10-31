#!/bin/bash


source config.sh
source fonction.sh

echo "
*************************************************************************************
*************************************************************************************
********************************Installation de Apache2 Server***********************
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
********************************Récupération de MediaWiki****************************
*************************************************************************************
*************************************************************************************
"

apt update > /dev/null
apt install -y wget unzip > /dev/null


wget https://nlempereur.ovh/mediawiki.zip

if [[ $? -ne 0 ]]; then
    echo -e "${erreur}
*************************************************************************************
***************************Erreur lors du téléchargement de MediaWiki****************
*************************************************************************************${blanc}"
    exit 1
fi

unzip mediawiki.zip
mv mediawiki* /var/www/mediawiki
rm mediawiki.zip

if [[ $? -eq 0 ]]; then
    echo -e "${valid}
*************************************************************************************
*****************************Extraction vers /var/www/ OK !***************************
*************************************************************************************${blanc}
"
else
    echo -e "${erreur}
*************************************************************************************
********************************Erreur dans l'extraction*****************************
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
    DocumentRoot /var/www/mediawiki

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/mediawiki>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/mediawiki.conf

a2ensite mediawiki.conf > /dev/null
chown -R www-data:www-data /var/www/mediawiki

echo "
*************************************************************************************
******************************Configuration de la BDD *******************************
*************************************************************************************
"

read -p "Nom de l'utilisateur MySQL à créer : " nom
read -s -p "Mot de passe pour l'utilisateur : " Mdp

mysql -u root -e "
CREATE DATABASE IF NOT EXISTS mediawiki;
CREATE USER IF NOT EXISTS '$nom'@'localhost' IDENTIFIED BY '$Mdp';
GRANT ALL PRIVILEGES ON mediawiki.* TO '$nom'@'localhost';
FLUSH PRIVILEGES;
" 

systemctl restart apache2

if [[ $? -eq 0 ]]; then
    echo -e "${valid}
*************************************************************************************
********************************Installation réussie*********************************
*************************************************************************************${blanc}

******************************************************
Connectez-vous à cette IP sur le poste client : 
${valid}$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1)${blanc}
******************************************************

**********************************************************
Chemin de votre page web : ${valid}/var/www/mediawiki${blanc}
**********************************************************
Nom de la BDD   : ${valid}mediawiki${blanc}
Utilisateur BDD : ${valid}$nom${blanc}
Mot de passe    : ${valid}$Mdp${blanc}
**********************************************************
"
else
    echo -e "${erreur}
*************************************************************************************
*****************************Erreur lors de l'installation***************************
*************************************************************************************${blanc}
"
fi

echo "[Appuyez sur Entrée pour continuer]"
read
