#!/usr/bin/env bash

if [ $# -ne 3 ]; then
    echo "Usage: $0 <dossiers_dumps> <dossiers_contextes> <langue>"
    exit 1
fi

input_dumps=$1
input_contextes=$2
langue=$3

rep_pals="../pals/"
output_dump="${rep_pals}dump-${langue}.txt"
output_contexte="${rep_pals}contexte-${langue}.txt"

# Création des fichiers de sortie (les vider s'ils existent déjà)
> "$output_dump"
> "$output_contexte"

# Vérifier si thulac sont installés
if ! python3 -c "import thulac" &> /dev/null; then
    echo "thulac n'est pas installé. Veuillez utiliser 'pip install thulac' pour l'installer."
    exit 1
fi

filter_chinese() {
    python3 -c "
import sys
import re
input_file = sys.argv[1]
output_file = sys.argv[2]

with open(input_file, 'r', encoding='utf-8') as infile, open(output_file, 'w', encoding='utf-8') as outfile:
    for line in infile:
        clean_line = re.sub(r'[^\u4e00-\u9fff\n]', '', line)
        if clean_line.strip():
            outfile.write(clean_line + '\n')
" "$1" "$2"
}

# Fonction pour traiter les fichiers avec thulac
process_with_thulac() {
    python3 -c "
import sys
import thulac

thu = thulac.thulac(seg_only=True)

# Lire le fichier d'entrée
with open(sys.argv[1], 'r', encoding='utf-8') as infile:
    lines = infile.readlines()

# Ouvrir le fichier de sortie
with open(sys.argv[2], 'a', encoding='utf-8') as outfile:
    for line in lines:
        if not line.strip():  # Conserver les lignes vides
            outfile.write('\n')
        else:
            # Segmentation avec thulac
            segmented = thu.cut(line.strip(), text=True)
            outfile.write('\n'.join(segmented.split()) + '\n')  # Un mot par ligne
    outfile.write('\n')  # Ajouter une ligne vide entre les fichiers
" "$1" "$2"
}


# Traiter les fichiers dumps
echo "Traitement des fichiers dumps..."
for file in "$input_dumps"/dump_"$langue"_*.txt; do
    if [ -f "$file" ]; then
        echo "  -> Traitement de $file"
        temp_file="${file}_temp.txt"  
        filter_chinese "$file" "$temp_file"  #  Filtrer uniquement les caractères chinois
        process_with_thulac "$temp_file" "$output_dump"  
        rm "$temp_file"  
    fi
done
echo "Les fichiers dumps segmentés ont été fusionnés dans : $output_dump"

# Traiter les fichiers contextes
echo "Traitement des fichiers contextes..."
for file in "$input_contextes"/context_"$langue"_*.txt; do
    if [ -f "$file" ]; then
        echo "  -> Traitement de $file"
        temp_file="${file}_temp.txt"  
        filter_chinese "$file" "$temp_file"  
        process_with_thulac "$temp_file" "$output_contexte" 
        rm "$temp_file" 
    fi
done
echo "Les fichiers contextes segmentés ont été fusionnés dans : $output_contexte"