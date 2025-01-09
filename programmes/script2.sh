#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <fichier_urls>"
    exit 1
fi

FICHIER_URLS=$1
OUTPUT_HTML="ch.html"

line_nb=1

echo "<!DOCTYPE html>
<html>
<head>
    <title>Résultats des URLs</title>
</head>
<body>
<table border='1'>
    <tr>
        <th>Numéro</th>
        <th>URL</th>
        <th>Code HTTP</th>
        <th>Encodage</th>
    </tr>" > $OUTPUT_HTML

while read -r line; do
    code=$(curl -o /dev/null -s -w "%{http_code}" "$line")

    if [ "$code" -ne 200 ]; then
        echo "Erreur : $line retourne un code $code. URL non traitée." >&2
        echo "<tr>
                <td>$line_nb</td>
                <td>$line</td>
                <td>$code</td>
                <td>absent</td>
              </tr>" >> $OUTPUT_HTML
    else
        encoding=$(curl -sI "$line" | grep -i "Content-Type" | sed -n "s/.*charset=\(.*\)/\1/p")
        [ -z "$encoding" ] && encoding="Non spécifié"

        echo "$line est traitable."
        echo "<tr>
                <td>$line_nb</td>
                <td>$line</td>
                <td>$code</td>
                <td>$encoding</td>
              </tr>" >> $OUTPUT_HTML
    fi

    line_nb=$((line_nb + 1))
done < "$FICHIER_URLS"

echo "</table>
</body>
</html>" >> $OUTPUT_HTML

echo "Résultats enregistrés dans $OUTPUT_HTML"