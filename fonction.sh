#!/bin/bash
source config.sh

log=$(whoami)


# fonction pour afficher les titres
function afficheTitre () {
        figlet $1  
}

function validIP() {
    result=0
    # Diviser l'adresse IP en parties
    for i in {1..4}; do
        part=$(echo $1 | cut -d '.' -f $i)
        longeur=$(expr length "$part")
        # Vérifier la longueur de la partie
        if [[ $longeur -lt 1 || $longeur -gt 3 ]]; then
            result=1
            break
        fi
        # Vérifier chaque caractère de la partie
        for ((j=0; j<longeur; j++)); do
            el=${part:$j:1}
            ASCII=$(printf "%d" "'$el")
            # Vérifier si le caractère est un chiffre entre 0 et 9
            if [[ $ASCII -lt 48 || $ASCII -gt 57 ]]; then
                result=1
                break
            fi
        done
        # Vérifier si la partie est un nombre valide (0-255)
        if [[ $result -eq 0 && ( $part -lt 0 || $part -gt 255 ) ]]; then
            result=1
            break
        fi
    done

    # Afficher le résultat
    if [[ $result -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}


function validMAC() {
    result=0
    # Vérifier si l'adresse MAC a le bon format
    if [[ ${#1} -ne 17 ]]; then
        result=1
    fi
    # Diviser l'adresse MAC en parties
    for i in {1..6}; do
    part=$(echo $1 | cut -d ':' -f $i)
    # Vérifier la longueur de la partie
    longeur=$(expr length "$part")
        if [[ $longeur -ne 2 ]]; then
            result=1
            break
        fi
        # Vérifier si chaque caractère est un chiffre hexadécimal
        for ((j=0; j<longeur; j++)); do
            el=${part:$j:1}
            ASCII=$(printf "%d" "'$el")
            # Vérifier si le caractère est un chiffre hexadécimal (0-9, A-F, a-f)
            if ! [[ ($ASCII -ge 48 && $ASCII -le 57) || ($ASCII -ge 65 && $ASCII -le 70) || ($ASCII -ge 97 && $ASCII -le 102) ]]; then
                result=1
                break
            fi
        done
        if [[ $result -eq 1 ]]; then
            break
        fi
    done
    # Afficher le résultat
    if [[ $result -eq 0 ]]; then
        return 0  
    else
        return 1  
    fi
}
