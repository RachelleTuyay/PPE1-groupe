#!/usr/bin/env bash

if [ $# -ne 3 ]; then
    echo "Usage : $0 <dumps> <contextes> <langue>"
    exit 1
fi

input_dumps=$1
input_contextes=$2
langue=$3

rep_pals="./pals/"
output_dump="${rep_pals}dump-tr.txt"
output_contexte="${rep_pals}contexte-tr.txt"

if [ ! -d "$rep_pals" ]; then
    mkdir -p "$rep_pals"
fi

> "$output_dump"
> "$output_contexte"

for file in "$input_dumps"/*_tr_*.txt; do
    echo "Processing dump file: $file"
    if [ -f "$file" ]; then
        awk '
        {
            if (NF == 0) {
                print ""
            } else {
                for (i = 1; i <= NF; i++) {
                    print $i
                }
            }
        }
        END {
            print ""
        }
        ' "$file" >> "$output_dump"
    fi
done
echo "Les fichiers tokenisés seront fusionnés dans : $output_dump"

# Process only _tr_ context files
for file in "$input_contextes"/*_tr_*.txt; do
    echo "Processing context file: $file"
    if [ -f "$file" ]; then
        awk '
        {
            if (NF == 0) {
                print ""
            } else {
                for (i = 1; i <= NF; i++) {
                    print $i
                }
            }
        }
        END {
            print ""
        }
        ' "$file" >> "$output_contexte"
    fi
done
echo "Les fichiers tokenisés seront fusionnés dans : $output_contexte"
