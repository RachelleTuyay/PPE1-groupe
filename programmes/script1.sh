#!/usr/bin/bash

if [ $# -ne 1 ]
then
    echo "$0 ce programme demande un argument."
    exit 1
fi

FICHIER_URLS=$1
#occurences=$2
#aspirations=$3
#dumps=$4

line_nb=1


while read -r line
do
    #$aspirations=  #stocke les pages aspirées

    #$dumps=   #stocke les dumps textuels récupés

    code=$(curl -s -I -L -w "%{http_code}" -o /dev/null $line) #extract the code from url
    encoding=$(curl -o /dev/null -s -I -L -w "%{content_type}" $line | grep -Po "charset=\S+" | cut -d "=" -f2 | tr -d "\r\n")   #extract the encoding from url

    #nb_mots=$(lynx -dump -nolist $line | wc -w)

    if [ $code -eq 200 ];
    then
        echo "$line est traitable."
    else
        echo "$line n'est pas traitable. $code"
        exit 2
    fi

    #$occurences = grep "coeur" | wc -c   #compte l'occurences du mot coeur


    echo -e "$line_nb\t$line\t$code\t$encoding\t$aspirations\t$dumps" #tableau
    line_nb=$((line_nb+1))

done < $FICHIER_URLS


