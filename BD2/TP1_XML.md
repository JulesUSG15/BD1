# Compte Rendu de TP: TP1 BD2 - XML Ginhac Jules

## I. Interrogation de documents XML via XPath

1. **Analyse des Requêtes XPath sur la pièce de Shakespeare "Hamlet"**

   - `//ACT/TITLE`  
     **Description :** Cette requête sélectionne tous les éléments `<TITLE>` qui sont enfants directs de tout élément `<ACT>`.  
     **Code :** Utilisation de l'atelier XQuery pour exécuter la requête.  
     **Résultat :** Renvoie les titres de tous les actes de la pièce.

   - `//LINE/TITLE`  
     **Description :** Tente de sélectionner des éléments `<TITLE>` enfants de `<LINE>`, mais aucun `<TITLE>` n'est enfant de `<LINE>`.  
     **Correction proposée :** Comme `<LINE>` ne contient pas de `<TITLE>`, cette requête ne peut pas être corrigée sans modifier la structure ou l'intention de la requête.  

   - `//SPEECH/following-sibling::TITLE`  
     **Description :** Cette requête recherche des éléments `<TITLE>` qui sont des frères suivants de `<SPEECH>`. Cependant, `<TITLE>` ne se trouve pas au même niveau hiérarchique que `<SPEECH>`.  
     **Correction proposée :** Si l'intention est de trouver des titres qui suivent immédiatement des discours, une meilleure approche serait nécessaire, car la structure actuelle ne supporte pas cette requête.

   - `//SCENE/SPEECH[3]/LINE[2]`  
     **Description :** Sélectionne la deuxième ligne du troisième discours dans chaque scène.  
     **Code :** Utilisation de l'atelier XQuery pour exécuter la requête.  
     **Résultat :** Renvoie la ligne spécifiée de chaque discours si elle existe.

2. **Traduction des Requêtes en XPath**

   - **Donner l'ensemble des lignes dites par Hamlet ou Horatio**
     ```xpath
     //SPEECH[SPEAKER = "HAMLET" or SPEAKER = "HORATIO"]/LINE
     ```
   
   - **Donner les titres des scènes dans lesquelles Horatio répond à Hamlet**
     ```xpath
     //SCENE[SPEECH/SPEAKER = "HAMLET" and following-sibling::SPEECH[1]/SPEAKER = "HORATIO"]/TITLE
     ```
   
   - **Donner le nombre de personnes différentes ayant parlé des discours commencant par "Who"**
     ```xpath
     count(distinct-values(//SPEECH[LINE[starts-with(., "Who")]]/SPEAKER))
     ```

## II. Extraction de données relationnelles en XML

### Utilisation de la Fonction XMLElement**
   
   - **Requête pour générer un élément XML pour chaque artiste**
     ```sql
     SELECT XMLElement("artiste", 
            XMLElement("nom", nom_artiste),
            XMLElement("prenom", prenom_artiste))
     FROM artistes;
     ```

### Utilisation de XMLAttributes et XMLForest**
   
   - **Requête avec XMLAttributes pour générer un élément "artiste"**
     ```sql
     SELECT XMLElement("artiste",
           XMLAttributes(id_artiste AS "id", annee_naissance AS "annee_naissance"),
           nom_artiste)
     FROM artistes;
     ```

   - **Modification avec XMLForest pour structurer les éléments "nomArtiste" et "prenomArtiste"**
     ```sql
     SELECT XMLElement("artiste",
           XMLAttributes(id_artiste AS "id", annee_naissance AS "annee_naissance"),
           XMLForest(nom_artiste AS "nomArtiste", prenom_artiste AS "prenomArtiste"))
     FROM artistes;
     ```

### II.4. XMLAgg

1. **Modification de la requête pour ajouter les films pour chaque artiste**

   Pour inclure un élément "ses_films" qui liste tous les films par artiste avec des détails, on utilise `XMLAgg` pour agréger ces films sous chaque artiste :

   ```sql
   SELECT XMLElement("artiste",
          XMLAttributes(id_artiste AS "id", annee_naissance AS "annee_naissance"),
          XMLElement("nomArtiste", nom_artiste),
          XMLElement("prenomArtiste", prenom_artiste),
          XMLElement("ses_films",
              XMLAgg(
                  XMLElement("film",
                      XMLAttributes(id_film AS "id_film", annee_sortie AS "annee_sortie"),
                      titre_film
                  )
              )
          )
      )
   FROM artistes
   JOIN films ON artistes.id_artiste = films.id_artiste
   GROUP BY id_artiste, annee_naissance, nom_artiste, prenom_artiste;
   ```

   Cette requête génère pour chaque artiste un XML comprenant une liste de ses films.

2. **Utilisation de LEFT OUTER JOIN**

   Si on remplace `JOIN` par `LEFT OUTER JOIN`, cela permet d'inclure les artistes même s'ils n'ont pas de rôles dans des films. Les artistes sans films auront un élément "ses_films" vide.

   ```sql
   SELECT XMLElement("artiste",
          XMLAttributes(id_artiste AS "id", annee_naissance AS "annee_naissance"),
          XMLElement("nomArtiste", nom_artiste),
          XMLElement("prenomArtiste", prenom_artiste),
          XMLElement("ses_films",
              XMLAgg(
                  XMLElement("film",
                      XMLAttributes(id_film AS "id_film", annee_sortie AS "annee_sortie"),
                      titre_film
                  )
              )
          )
      )
   FROM artistes
   LEFT OUTER JOIN films ON artistes.id_artiste = films.id_artiste
   GROUP BY id_artiste, annee_naissance, nom_artiste, prenom_artiste;
   ```

### II.5. Vues

1. **Création d'une vue pour chaque artiste**

   ```sql
   CREATE VIEW vue_artistes AS
   SELECT id_artiste, XMLElement("artiste",
       XMLAttributes(id_artiste AS "id", annee_naissance AS "annee_naissance"),
       XMLElement("nomArtiste", nom_artiste),
       XMLElement("prenomArtiste", prenom_artiste),
       XMLElement("ses_films",
           XMLAgg(
               XMLElement("film",
                   XMLAttributes(id_film AS "id_film", annee_sortie AS "annee_sortie"),
                   titre_film
               )
           )
       )
   ) AS representation_xml
   FROM artistes
   LEFT OUTER JOIN films ON artistes.id_artiste = films.id_artiste
   GROUP BY id_artiste, annee_naissance, nom_artiste, prenom_artiste;
   ```

2. **Création d'une vue contenant tous les artistes**

   ```sql
   CREATE VIEW vue_tous_artistes AS
   SELECT XMLElement("tous_artistes",
       XMLAgg(
           (SELECT representation_xml FROM vue_artistes)
       )
   ) AS document_xml;
   ```

### II.6. Manipulation de la Vue Obtenue

1. **Requête XQuery pour transformer en HTML**

   ```sql
   SELECT XMLQuery('
       <html>
       <body>
       <ol>{
           for $artist in /artiste
           return <li><a href="mailto:{$artist/nomArtiste}.{$artist/prenomArtiste}@aol.com">
                   {$artist/nomArtiste} {$artist/prenomArtiste}</a>
                   <p>Ses films sont:
                   <ul>{
                       for $film in $artist/ses_films/film
                       return <li>{$film}</li>
                   }</ul>
                   </p>
               </li>
       }</ol>
       </body>
       </html>
   ' PASSING vue_tous_artistes.document_xml AS "artiste"
   RETURNING CONTENT);
   ```

2. **Copie du résultat dans un fichier texte**

   L'enregistrement du résultat HTML dans un fichier texte pourrait être réalisé via une application ou un script qui exécute la requête et stocke le résultat. Vous pourriez ensuite ouvrir ce fichier dans un navigateur pour vérifier le formatage et le contenu.