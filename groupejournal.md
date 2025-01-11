Hongying XU:   

Du 31/12/2024 au 09/01/2025   

Creation du fichier groupejournal.md et ajout les dossiers des exercices.    
Ajout script pour traiter les urls et voir s'ils sont traitables, les écrire dans le fichier HTML.    
Modifier script pour stocker les pages aspirées et les dumps textuels.    
Modifier script pour Compter les occurrences.    
Modifier script pour les contextes et les concordances.  

Le 10/01/2024 :  
Ajout du script make_pals_corpus_ch.sh basé du make_pals_corpus_fr.sh, mais j'ajoute thulac pour segmenter les caracteres chinois et une fonction pour nettoyer en supprimant tous les caractères sauf les caractères chinois.

-----------------------------------------------------------------

Rachelle TUYAY:
Création du dépôt (en tant que Owner)

Le 11/12/2024 :
Création du `script1.sh` qui vérifie les urls si ils ont bien un code de "200".
Ajout de `urls-fr.txt`, où le 7ème lien provoquera une erreur 404 avec le `script1.sh` pour montrer que le script fonctionne ainsi que pour les autres scripts.

Le 10/01/2024 :
Ajout du `scriptfr.sh`, ainsi que les fichiers fr dans les dossiers aspirations, contextes, concordances, dumps-text et tableaux.
- Le `scriptfr.sh` s'est basé du `scriptch.sh`, qui a été modifié par la suite pour opter un style (CSS avec bulma) différents et réadapté pour ubuntu (car Hongying est sur Mac).
Ajout du `make_pals_corpus_fr.sh`, qui tokénize et stocke la tokénisatiton à chaque fichier. Ce script traite les fichiers `dumps-text` et `contextes`. Pour la tokénisation, ce script va séparer chaque mot par un saut de ligne (donc on obtient un mot par ligne) et il va séparer les phrases par une ligne vide.
Ajout de `index.html` :
- `index.html` n'est pas fini, mais c'est un croquis du "site web" avec un début de texte et un peu de CSS de Bulma. 
-----------------------------------------------------------------

Dilay DUZLER :

Le 10/01/2025: 
Collecte des URLs en turc: J'ai commencé par collecter des URLs en turc.

Écriture d'un script pour contrôler les URLs (scripttr-control.sh) turques et vérification des URLs: J'ai écrit un script pour contrôler les URLs, en vérifiant leur accessibilité via leur code

Il y avait beaucoup d'URLs avec un code différent de 200. Par conséquent, j'ai modifié le script pour supprimer automatiquement ces URLs du fichier.

Création du script scripttr.sh, J'ai toujours manqué un URL

Ajout d'une commande echo a la fin pour identifier l'URL manquante

Le 11/01/2025: 

Le tableau ne fonctionnait pas, j'ai ajouté Bulma CSS.

Deux des liens étaient cassés, je les ai corrigés.