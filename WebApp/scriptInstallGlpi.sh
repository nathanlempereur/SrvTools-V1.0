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
********************************Récupération de GLPI*********************************
*************************************************************************************
*************************************************************************************
"

apt update > /dev/null
apt install -y wget tar > /dev/null

wget https://nlempereur.ovh/glpi.tgz

if [[ $? -ne 0 ]]; then
    echo -e "${erreur}
*************************************************************************************
***************************Erreur lors du téléchargement de GLPI*********************
*************************************************************************************${blanc}"
    exit 1
fi

tar -xzf glpi.tgz
mv glpi /var/www/ > /dev/null 2>&1
rm glpi.tgz

if [[ $? -eq 0 ]]; then
    echo -e "${valid}
*************************************************************************************
********************************Extraction vers /var/www/ OK !***********************
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
    DocumentRoot /var/www/glpi
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/glpi>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/glpi.conf


a2ensite glpi.conf > /dev/null
a2enmod php* > /dev/null 2>&1
a2enmod rewrite > /dev/null 2>&1
chown -R www-data:www-data /var/www/glpi

read -p "Nom de l'utilisateur MySQL à créer : " nom
read -s -p "Mot de passe pour l'utilisateur : " Mdp

mysql -u root -e "
CREATE DATABASE IF NOT EXISTS glpi;
CREATE USER IF NOT EXISTS '$nom'@'localhost' IDENTIFIED BY '$Mdp';
GRANT ALL PRIVILEGES ON glpi.* TO '$nom'@'localhost';
FLUSH PRIVILEGES;
"

systemctl restart apache2

if [[ $? -eq 0 ]]; then
    echo -e "${valid}
*************************************************************************************
********************************Installation réussie*********************************
*************************************************************************************${blanc}

******************************************************
Connectez-vous à cette IP sur le poste client : ${valid}$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1)${blanc}******
******************************************************


**********************************************************
Chemin du site web : ${valid}/var/www/glpi${blanc}
**********************************************************
Nom de la base   : ${valid}glpi${blanc}
Nom de l’utilisateur : ${valid}$nom${blanc}
Mot de passe     : ${valid}$Mdp${blanc}
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
