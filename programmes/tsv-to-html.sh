#!/bin/bash

# Vérifie qu'un fichier TSV a été fourni en argument
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <fichier_tsv> <fichier_html> <langue>"
    exit 1
fi

# Fichier TSV en entrée
tsv_file="$1"

# Fichier HTML en sortie
html_file="$2"
langue="$3"

# Vérifie si le fichier TSV existe
if [ ! -f "$tsv_file" ]; then
    echo "Erreur : le fichier $tsv_file n'existe pas."
    exit 1
fi

# Début du fichier HTML + création du fichier html :
echo "<!DOCTYPE html>" > "$html_file"
echo "
<html>
    <head>
        <title>Tableau TSV ($langue)</title>
        <link href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css\" rel=\"stylesheet\">
        <style>
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f4f4f4; }
        .highlight { font-weight: bold; color: red; }
        h1 {font-size: 32px; color: red; padding:16px; text-align:center; display:block; margin:16px;}
    </style>
    </head>

    <body>
    <h1>Textométrie ($langue):</h1>

    <div class=table-container>
        <table class=table is-bordered is-striped is-narrow is-hoverable is-fullwidth>" >> "$html_file"

# Lecture du fichier TSV et conversion en HTML
{
    IFS=$'\t' # Définir le séparateur sur TAB
    read -r header_line # Lire la première ligne (en-tête)
    echo "<tr>" >> "$html_file"
    for header in $header_line; do
        echo "<th>$header</th>" >> "$html_file"
    done
    echo "</tr>" >> "$html_file"

    # Lire le reste des lignes
    while read -r line; do
        echo "<tr>" >> "$html_file"
        for cell in $line; do
            echo "<td>$cell</td>" >> "$html_file"
        done
        echo "</tr>" >> "$html_file"
    done
} < "$tsv_file"

# Fin du tableau et du fichier HTML
echo "
            </table>
        </div>
    </body>
</html>" >> "$html_file"

echo "Conversion terminée : le fichier HTML a été enregistré dans $html_file"
