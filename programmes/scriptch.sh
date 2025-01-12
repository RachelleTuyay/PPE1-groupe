#!/usr/bin/env bash

if [ $# -ne 3 ]; then
    echo "Usage : $0 <fichier contenant les URLs> <langue> <mot cible>"
    exit 1
fi

script_dir=$(cd "$(dirname "$0")" && pwd) 
parent_dir=$(dirname "$script_dir")

fichier_urls=$1   
langue=$2          
mot_cible=$3     

rep_aspirations="$parent_dir/aspirations"
rep_dumps="$parent_dir/dumps-text"
rep_contextes="$parent_dir/contextes"
rep_concordances="$parent_dir/concordances"
rep_tableaux="$parent_dir/tableaux"
tableau_html="${rep_tableaux}/tableau_${langue}.html"

cat <<HTML_HEADER > "$tableau_html"
<!DOCTYPE html>
<html lang="$langue">
<head>
    <meta charset="UTF-8">
    <title>Tableau des résultats ($langue)</title>
    <style>
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f4f4f4; }
        .highlight { font-weight: bold; color: red; }
    </style>
</head>
<body>
    <h1>Résultats des URLs ($langue)</h1>
    <table>
        <thead>
            <tr>
                <th>#</th>
                <th>URL</th>
                <th>Encodage</th>
                <th>Nombre de mots</th>
                <th>Occurrences</th>
                <th>Aspiration</th>
                <th>Dump</th>
                <th>Contexte</th>
                <th>Concordance</th>
            </tr>
        </thead>
        <tbody>
HTML_HEADER

ligne_id=1

while IFS= read -r url; do
    echo "Traitement de l'URL $url ..."

    
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")

    if [[ "$http_code" != 2* && "$http_code" != 3* ]]; then
        echo "URL invalide ou introuvable : $url (HTTP $http_code)" >&2
        echo "<tr>
              <td>$ligne_id</td>
              <td><a href=\"$url\">$url</a></td>
              <td>/</td>
              <td>/</td>
              <td>/</td>
              <td>/</td>
              <td>/</td>
              <td>/</td>
              <td>/</td>
              </tr>" >> "$tableau_html"
    else
        fichier_html="$rep_aspirations/page_${langue}_${ligne_id}.html"
        fichier_dump="$rep_dumps/dump_${langue}_${ligne_id}.txt"
        fichier_context="$rep_contextes/context_${langue}_${ligne_id}.txt"
        fichier_concordance="$rep_concordances/concordance_${langue}_${ligne_id}.html"

       
        curl -s -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:92.0) Gecko/20100101 Firefox/92.0" "$url" -o "$fichier_html"

       
        content_type=$(curl -sI -L "$url" | grep -i "Content-Type")
        encodage=$(echo "$content_type" | grep -oE 'charset=[^;]+' | cut -d'=' -f2)
        
        if [ -z "$encodage" ] || [ "$encodage" == "N/A" ]; then
        encodage=$(grep -i '<meta' "$fichier_html" | grep -oE 'charset=[^"]+' | cut -d'=' -f2)
        fi
        
        if [ -z "$encodage" ]; then
            encodage="UTF-8"
        fi

        
        lynx -dump -nolist -assume_charset="$encodage" -display_charset=UTF-8 "$fichier_html" > "$fichier_dump"

       
        sed -i '' 's/[^[:print:]\t]//g' "$fichier_dump"

       
        total_mots=$(wc -w < "$fichier_dump")

        
        total_occurrences=$(grep -o "$mot_cible" "$fichier_dump" | wc -l)

       
        grep -C 1 "$mot_cible" "$fichier_dump" > "$fichier_context"

        
cat <<CONCORDANCE_HEADER > "$fichier_concordance"
<!DOCTYPE html>
<html lang="$langue">
<head>
    <meta charset="UTF-8">
    <title>Concordance ($langue)</title>
    <style>
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f4f4f4; }
        .highlight { font-weight: bold; color: red; }
    </style>
</head>
<body>
    <h1>Concordance des mots-clés ($langue)</h1>
    <table>
        <thead>
            <tr>
                <th>Contexte gauche</th>
                <th>Mot</th>
                <th>Contexte droit</th>
            </tr>
        </thead>
        <tbody>
CONCORDANCE_HEADER

        grep -oE ".{0,30}$mot_cible.{0,30}" "$fichier_dump" | while read -r line; do
    left=$(echo "$line" | sed -E "s/(.*)($mot_cible)(.*)/\1/")
    right=$(echo "$line" | sed -E "s/(.*)($mot_cible)(.*)/\3/")
    echo "<tr>
            <td>$left</td>
            <td class='highlight'>$mot_cible</td>
            <td>$right</td>
          </tr>" >> "$fichier_concordance"
done

cat <<CONCORDANCE_FOOTER >> "$fichier_concordance"
        </tbody>
    </table>
</body>
</html>
CONCORDANCE_FOOTER

        echo "<tr>
                <td>$ligne_id</td>
                <td><a href=\"$url\">$url</a></td>
                <td>${encodage:-UTF-8}</td>
                <td>$total_mots</td>
                <td>$total_occurrences</td>
                <td><a href=\"$fichier_html\">HTML</a></td>
                <td><a href=\"$fichier_dump\">Dump</a></td>
                <td><a href=\"$fichier_context\">Contexte</a></td>
                <td><a href=\"$fichier_concordance\">Concordance</a></td>
              </tr>" >> "$tableau_html"
    fi

    ligne_id=$((ligne_id + 1))
done < "$fichier_urls"

cat <<HTML_FOOTER >> "$tableau_html"
        </tbody>
    </table>
</body>
</html>
HTML_FOOTER

echo "Tableau généré avec succès : $tableau_html"