#!/bin/bash

# Import des configs et fonctions
source config.sh
source fonction.sh

echo "
*************************************************************************************
*************************************************************************************
********************************Installation de Fail2Ban*****************************
*************************************************************************************
*************************************************************************************
"

apt update > /dev/null
apt install -y fail2ban iptables

quitter=1
while [[ $quitter -ne 0 ]]
do
    echo ""
    echo "1) Configuration SSHD"
    echo "2) Configuration Apache"
    echo "0) Quitter"
    echo -ne "Veuillez choisir une option : "
    read choix

    case $choix in 
        1 )
            echo ""
            read -p "Nombre de tentatives maximum ? : " try
            read -p "Temps de recherche (en secondes) ? : " find
            read -p "Durée de bannissement (en secondes) ? : " ban
            read -p "Port SSH ? (22 par défaut) : " port
            if [[ -z "$port" ]]; then
                port=22
            fi

            echo "[sshd]
enabled = true
bantime = $ban
findtime = $find
maxretry = $try
backend = systemd
ignoreip = 127.0.0.1
port = $port
logpath = /var/log/auth.log" > /etc/fail2ban/jail.d/sshd.conf

            systemctl restart fail2ban

            if [[ $? -eq 0 ]]; then
                echo -e "${valid}
*************************************************************************************
********************************Configuration SSHD réussie***************************
*************************************************************************************${blanc}"
            else
                echo -e "${erreur}
*************************************************************************************
*******************************Erreur lors de la configuration SSHD******************
*************************************************************************************${blanc}"
            fi

            echo -e "Le fichier de configuration est : ${valid}/etc/fail2ban/jail.d/sshd.conf${blanc}"
        ;;
        
        2 )
            echo ""
            read -p "Nombre de tentatives maximum ? : " try
            read -p "Temps de recherche (en secondes) ? : " find
            read -p "Durée de bannissement (en secondes) ? : " ban
            read -p "Port Apache ? (80 par défaut) : " port
            if [[ -z "$port" ]]; then
                port=80
            fi

            echo "[apache-auth]
enabled = true
bantime = $ban
findtime = $find
maxretry = $try
backend = auto
ignoreip = 127.0.0.1
port = $port
logpath = /var/log/apache2/error.log" > /etc/fail2ban/jail.d/apache.conf

            systemctl restart fail2ban

            if [[ $? -eq 0 ]]; then
                echo -e "${valid}
*************************************************************************************
********************************Configuration Apache réussie*************************
*************************************************************************************${blanc}"
            else
                echo -e "${erreur}
*************************************************************************************
*******************************Erreur lors de la configuration Apache****************
*************************************************************************************${blanc}"
            fi

            echo -e "Le fichier de configuration est : ${valid}/etc/fail2ban/jail.d/apache.conf${blanc}"
        ;;
        
        0 )
            quitter=0
        ;;
        
        * )
            echo -e "${erreur}Erreur : choix invalide.${blanc}"
        ;;
    esac
done
