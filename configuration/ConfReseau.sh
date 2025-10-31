#!/bin/bash

source config.sh
source fonction.sh

cat /etc/network/interfaces > /etc/network/oldinterfaces

read -p "Carte Ethernet ou Wifi ? (e/w) : " type
while [ "$type" != "e" ] && [ "$type" != "w" ]; do
    	echo "Saisie incorrecte."
    	read -p "Carte Ethernet ou Wifi ? (e/w) : " type
done

read -p "Le nom de la carte : " nom
if [[ "$type" == "w" ]]; then
    read -p "Le nom du wifi : " wifi
    read -s -p "Le Mdp du wifi : " Mdp
fi

read -p "Voulez-vous configurer une IP fixe ? (o/n) : " reponse
while [ "$reponse" != "o" ] && [ "$reponse" != "n" ]; do
    	echo "Saisie incorrecte."
    	read -p "Voulez-vous configurer une IP fixe ? (o/n) : " reponse
done
if [[ "$reponse" == "o" ]]; then
    read -p "Entrez l'adresse IP : " address
    read -p "Entrez le masque : " netmask
    read -p "Entrez la passerelle : " gateway
    read -p "Entrez le DNS : " dns

    echo "
# Interface loopback
auto lo
iface lo inet loopback

# Configuration de l'interface réseau en IP statique
allow-hotplug $nom
iface $nom inet static
    address $address
    netmask $netmask
    gateway $gateway
    dns-nameservers $dns" > /etc/network/interfaces

if [[ "$type" == "w" ]]; then
echo "
    wpa-ssid $wifi
    wpa-psk $Mdp" >> /etc/network/interfaces
fi

    systemctl restart networking

    echo -e "
***********************************************
Votre config est : ****************************
Adresse IP : ${valid}$address${blanc}
Masque : ${valid}$netmask${blanc}
Passerelle : ${valid}$gateway${blanc}
DNS : ${valid}$dns${blanc}
***********************************************
Test de la configuration sur www.google.fr : **
***********************************************"
ping -c 3 www.google.fr > /dev/null

if [[ $? -eq 0 ]]; then
	echo -e "${valid}
***********************************************
Configuration OK ! ****************************
***********************************************${blanc}"
else
	echo -e "${erreur}
***********************************************
Erreur dans la configuration... ***************
***********************************************${blanc}
"
fi


else
    read -p "Voulez-vous configurer un DHCP ? (o/n) : " reponse2

    if [[ $reponse2 == "o" ]]; then
        echo "
# Interface loopback
auto lo
iface lo inet loopback

#DHCP
allow-hotplug $nom
iface $nom inet dhcp" > /etc/network/interfaces

if [[ "$type" == "w" ]]; then
echo "
    wpa-ssid $wifi
    wpa-psk $Mdp" >> /etc/network/interfaces
fi

	systemctl restart networking

	echo "
***********************************************
Test de la configuration sur www.google.fr : **
***********************************************"
ping -c 3 www.google.fr > /dev/null

	if [[ $? -eq 0 ]]; then
		echo -e "${valid}
***********************************************
Configuration OK ! ****************************
***********************************************${blanc}
***********************************************
Votre IP est :  ${valid}$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1)${blanc}  ****************************
***********************************************
"
	else
		echo -e "${erreur}
***********************************************
Erreur dans la configuration... ***************
***********************************************${blanc}
"
	fi

    fi
fi
echo "[Appuyer sur entrer pour continuer]"
read
