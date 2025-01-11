#!/usr/bin/env bash

if [ $# -ne 3 ]; then
    echo "Usage : $0 <fichier contenant les URLs> <langue> <mot cible>"
    exit 1
fi

fichier_urls=$1   
langue=$2          
mot_cible=$3     

rep_aspirations="./aspirations"
rep_dumps="./dumps-text"
rep_contextes="./contextes"
rep_concordances="./concordances"
rep_tableaux="./tableaux"
tableau_html="${rep_tableaux}/tableau_${langue}.html"

declare -a urls_faux

cat <<HTML_HEADER > "$tableau_html"
<!DOCTYPE html>
<html lang="$langue">
<head>
    <meta charset="UTF-8">
    <title>Tableau des résultats ($langue)</title>
    <link href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css" rel="stylesheet">
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            background-color: #f8f9fa;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        th, td {
            padding: 12px 16px;
            text-align: left;
            border-bottom: 1px solid #e9ecef;
        }
        th {
            background-color: #4CAF50;
            color: white;
            font-weight: bold;
        }
        td {
            color: #212529;
        }
        tr:hover {
            background-color: #f1f5f9;
            transition: background-color 0.2s ease-in-out;
        }
        .highlight {
            font-weight: bold;
            color: #e63946;
        }
        h1 {
            font-size: 36px;
            color: #4CAF50;
            text-align: center;
            margin: 20px 0;
            font-family: 'Arial', sans-serif;
            text-transform: uppercase;
            letter-spacing: 1.2px;
        }
        a {
            text-decoration: none;
            color: #007BFF;
            transition: color 0.3s ease-in-out;
        }
        a:hover {
            color: #0056b3;
        }
    </style>
</head>
<body>
    <h1> Résultats des URLs ($langue)</h1>
    <div class=table-container>
    <table class=table is-bordered is-striped is-narrow is-hoverable is-fullwidth>
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
    echo "Traitement de l'URL : $url ..."

    
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
    <link href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css" rel="stylesheet">
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            background-color: #f8f9fa;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        th, td {
            padding: 12px 16px;
            text-align: left;
            border-bottom: 1px solid #e9ecef;
        }
        th {
            background-color: #4CAF50;
            color: white;
            font-weight: bold;
        }
        td {
            color: #212529;
        }
        tr:hover {
            background-color: #f1f5f9;
            transition: background-color 0.2s ease-in-out;
        }
        .highlight {
            font-weight: bold;
            color: #e63946;
        }
        h1 {
            font-size: 36px;
            color: #4CAF50;
            text-align: center;
            margin: 20px 0;
            font-family: 'Arial', sans-serif;
            text-transform: uppercase;
            letter-spacing: 1.2px;
        }
        a {
            text-decoration: none;
            color: #007BFF;
            transition: color 0.3s ease-in-out;
        }
        a:hover {
            color: #0056b3;
        }
    </style>
</head>
<body>
    <h1>Concordance des mots-clés ($langue)</h1>
    <div class=table-container>
    <table class=table is-bordered is-striped is-narrow is-hoverable is-fullwidth>
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
    </div>
</body>
</html>
HTML_FOOTER


if [ ${#failed_urls[@]} -ne 0 ]; then
    echo -e "\n--- Les URLs faux: ---"
    for failed in "${urls_faux[@]}"; do
        echo "$failed"
    done
else
    echo "Toutes les URL traitées avec succès."
fi

echo "Tableau généré avec succès : $tableau_html"