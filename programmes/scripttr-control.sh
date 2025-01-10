#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage : $0 <fichier contenant les URLs>"
    exit 1
fi

fichier_urls=$1

while read -r url; do
    code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$code" -eq 200 ]; then
        echo "$url" >> "${fichier_urls}.tmp"
        echo "$url est accessible. (Code: $code)"
    else
        echo "$url n'est pas accessible. (Code: $code)"
    fi
done < "$fichier_urls"

sort "${fichier_urls}.tmp" | uniq > "$fichier_urls"
rm "${fichier_urls}.tmp"

echo "Les URLs non valides ont été supprimées et les doublons éliminés de $fichier_urls."
