#!/usr/bin/bash

if [ $# -ne 2 ];
then
    echo "Usage : $0 <dumps> <contextes> <langue>"
fi

input_dumps=$1
input_contextes=$2
langue=$3

rep_pals="../pals/"
output_dump="${rep_pals}dump-fr.txt"
output_contexte="${rep_pals}contexte-fr.txt"

# Création du fichier de sortie (vide si déjà existant)
> "$output_dump"
> "$output_contexte"

# Itération sur tous les fichiers dumps .txt :
for file in "$input_dumps"; do
    # Vérifie que c'est bien un fichier texte
    if [ -f "$file" ]; then
        # Tokenisation et ajout au fichier de sortie
        awk '
        {
            # Si la ligne est vide, conserve la ligne vide
            if (NF == 0) {
                print ""
            } else {
                # Sinon, sépare les mots et place chaque mot sur une ligne
                for (i = 1; i <= NF; i++) {
                    print $i
                }
            }
        }
        END {
            # Ajoute une ligne vide entre les fichiers
            print ""
        }
        ' "$file" >> "$output_dump"
    fi
done
echo "Les fichiers tokenisés seront fusionnés dans : $output_dump"

# Itération sur tous les fichiers contextes .txt :
for file in "$input_contextes"; do
    # Vérifie que c'est bien un fichier texte
    if [ -f "$file" ]; then
        # Tokenisation et ajout au fichier de sortie
        awk '
        {
            # Si la ligne est vide, conserve la ligne vide
            if (NF == 0) {
                print ""
            } else {
                # Sinon, sépare les mots et place chaque mot sur une ligne
                for (i = 1; i <= NF; i++) {
                    print $i
                }
            }
        }
        END {
            # Ajoute une ligne vide entre les fichiers
            print ""
        }
        ' "$file" >> "$output_contexte"
    fi
done
echo "Les fichiers tokenisés seront fusionnés dans : $output_contexte"

