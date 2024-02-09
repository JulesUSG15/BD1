# TP BDR 

# Partie 1 : prise en main d’oracle

## Exercice 1 :

## Exercice 2 :

a) Sur orapeda2, créez la table `tabletest` avec la commande SQL suivante :
```sql
CREATE TABLE tabletest (A INT, B VARCHAR2(50));
INSERT INTO tabletest VALUES (1, 'UN');
INSERT INTO tabletest VALUES (2, 'DEUX');
COMMIT;
```
Pour afficher le contenu, utilisez :
```sql
SELECT * FROM tabletest;
```

b) Pour créer un lien de base de données sur orapeda3 vers orapeda2, vous devez exécuter une commande semblable à :
```sql
CREATE DATABASE LINK connect_to_orapeda2
CONNECT TO BD2INIxx IDENTIFIED BY password
USING 'orapeda2';
```
(Remplacez `password` par votre mot de passe réel.)

c) Pour accéder à `tabletest` sur orapeda2 depuis orapeda3, utilisez :
```sql
SELECT * FROM tabletest@connect_to_orapeda2;
```

d) Pour retourner le contenu de la table `JOUEUR` stockée dans BDR sur orapeda2, la requête serait :
```sql
SELECT * FROM JOUEUR@connect_to_orapeda2;
```

## Exercice 3 :

a) SNous avons deux comptes sur deux instances Oracle différentes (orapeda2 et orapeda3), les liens sont unidirectionnels, donc on aura besoin de deux liens pour rendre toutes les données accessibles dans les deux sens. Un lien d'orapeda2 vers orapeda3 et un autre d'orapeda3 vers orapeda2.

b)
De orapeda3 vers orapeda2:
```sql
CREATE DATABASE LINK connect_to_orapeda2
CONNECT TO BD2INIxx IDENTIFIED BY password
USING 'orapeda2';
```

De orapeda2 vers orapeda3:
```sql
CREATE DATABASE LINK connect_to_orapeda3
CONNECT TO BD2INIxx IDENTIFIED BY mon_mot_de_passe
USING 'orapeda3';
```
## Exercice 3 :

a) Créez la table "Joueur" sur orapeda2 en sélectionnant les attributs nécessaires depuis la table existante sur orapeda 3 :
```sql
CREATE TABLE Joueur AS (SELECT * FROM Joueur@connect_to_orapeda2);
```

b) Vous avez utilisé le lien d'orapeda2 vers orapeda3.

c) Sur orapeda3, pour la table "Gain" :
```sql
CREATE TABLE Gain AS (SELECT * FROM Gain@connect_to_orapeda3);
```

d) Vous avez utilisé le lien d'orapeda3 vers orapeda2.

e) Toujours sur orapeda3, pour la table "Rencontre" :
```sql
CREATE TABLE Rencontre AS (SELECT * FROM Rencontre@connect_to_orapeda3);
```

f) Encore une fois, le lien d'orapeda3 vers orapeda2 a été utilisé.

Pour définir les contraintes de clés primaires sur les tables que nous avons créées, nous utilisons la commande `ALTER TABLE` comme suit :

Pour la table **Joueur** (en supposant que `nujoueur` est la clé primaire) :
```sql
ALTER TABLE Joueur ADD CONSTRAINT pk_Joueur PRIMARY KEY (nujoueur);
```

Pour la table **Gain** (avec `nujoueur`, `lieutournoi`, `annee` comme clés composées) :
```sql
ALTER TABLE Gain ADD CONSTRAINT pk_Gain PRIMARY KEY (nujoueur, lieutournoi, annee);
```

Pour la table **Rencontre** (avec `nuperdant`, `lieutournoi`, `annee` comme clés composées) :
```sql
ALTER TABLE Rencontre ADD CONSTRAINT pk_Rencontre PRIMARY KEY (nuperdant, lieutournoi, annee);
```

Exercice 5 :

a) **Création de la copie secondaire de "joueur" sur orapeda3** :
```sql
CREATE MATERIALIZED VIEW joueur_replica
REFRESH ON DEMAND
AS SELECT * FROM joueur@connect_to_orapeda2;
```
Puis, créez un log de modifications sur la table primaire "joueur" sur orapeda2 :
```sql
CREATE MATERIALIZED VIEW LOG ON joueur WITH PRIMARY KEY, ROWID;
```

b) **Création de la copie secondaire de "gain" sur orapeda2** :
```sql
CREATE MATERIALIZED VIEW gain_replica
REFRESH ON DEMAND WITH ROWID
AS SELECT * FROM gain@connect_to_orapeda3;
```
Et le log de modifications pour "gain" sur orapeda3 :
```sql
CREATE MATERIALIZED VIEW LOG ON gain WITH PRIMARY KEY, ROWID;
```

c) **Création de la copie secondaire de "rencontre" sur orapeda2** :
```sql
CREATE MATERIALIZED VIEW rencontre_replica
REFRESH COMPLETE START WITH SYSDATE NEXT SYSDATE + INTERVAL '5' MINUTE
AS SELECT * FROM rencontre@connect_to_orapeda3;
```
Et le log pour "rencontre" sur orapeda3 :
```sql
CREATE MATERIALIZED VIEW LOG ON rencontre WITH PRIMARY KEY, ROWID;
```

d) **Ajout de Toto dans "joueur" sur orapeda2 et rafraîchissement** :
```sql
INSERT INTO joueur VALUES (54, 'Toto', ...);
COMMIT;
```
Rafraîchir la vue matérialisée sur orapeda3 :
```sql
DBMS_MVIEW.REFRESH('joueur_replica');
```

e) **Ajout d'une victoire dans "rencontre" sur orapeda3 et rafraîchissement** :
```sql
INSERT INTO rencontre VALUES (54, 'Sampras', 'Roland Garros', 2010, ...);
COMMIT;
```
Rafraîchir "rencontre" sur orapeda2 :
```sql
DBMS_MVIEW.REFRESH('rencontre_replica');
```

**Suppression des répliques** pour "rencontre" après vérification :
```sql
DROP MATERIALIZED VIEW rencontre_replica;
```
## Exercice 6 :

a) Pour créer la vue **JoueurFrancaisSponsoriseParPeugeot (JFSPP)** sur orapeda2, qui affiche les joueurs français sponsorisés par 'Peugeot', la requête serait :

```sql
CREATE VIEW JoueurFrancaisSponsoriseParPeugeot (NuJoueur, PrenomNom) AS
SELECT NuJoueur, Prenom || ' ' || Nom
FROM Joueurs
WHERE Nationalite = 'Français' AND Sponsor = 'Peugeot';
```

b) Sur orapeda3, pour créer la vue **SommePrimeJoueurFrancaisSponsoriseParPeugeot (SPJPFSPP)** montrant la somme cumulée des primes pour chaque joueur français :

```sql
CREATE VIEW SommePrimeJoueurFrancaisSponsoriseParPeugeot (NuJoueur, SPrime) AS
SELECT NuJoueur, SUM(Prime)
FROM Gains
WHERE NuJoueur IN (SELECT NuJoueur FROM Joueurs WHERE Nationalite = 'Français' AND Sponsor = 'Peugeot')
GROUP BY NuJoueur;
```

# Partie 2 : fragmentation de bases

1) Pour réaliser la fragmentation horizontale de la table Secteur selon les hypothèses données :

- **À New-York (orapeda2)**, vous créez un fragment pour les pays d'Amérique avec la requête suivante :
  ```sql
  CREATE TABLE Secteur_Amerique AS SELECT * FROM Secteur WHERE Continent = 'Amérique';
  ```

- **À Lausanne (orapeda3)**, créez un fragment pour le reste du monde avec la commande :
  ```sql
  CREATE TABLE Secteur_ResteDuMonde AS SELECT * FROM Secteur WHERE Continent != 'Amérique';
  ```

Cela va diviser la table Secteur en deux parties : une contenant les pays d'Amérique stockée à New-York et l'autre avec les pays du reste du monde stockée à Lausanne.

2) Pour fragmenter horizontalement la table **Joueur** en se basant sur la localisation géographique des joueurs :

- **À New-York (orapeda2)**, pour stocker les joueurs américains, utilisez :
  ```sql
  CREATE TABLE Joueur_Americains AS SELECT * FROM Joueur WHERE nationalite = 'Américain';
  ```

- **À Lausanne (orapeda3)**, pour stocker les joueurs des autres nationalités, utilisez :
  ```sql
  CREATE TABLE Joueur_ResteDuMonde AS SELECT * FROM Joueur WHERE nationalite != 'Américain';
  ```

Cette approche divise la table **Joueur** en deux fragments selon la nationalité, répartissant les joueurs américains à New-York et tous les autres à Lausanne.

3) 

- **Sur orapeda2** (pour la table Rencontre, assumant une réplication depuis orapeda3 vers orapeda2) :
  ```sql
  -- Créer un log de modifications sur la table originale si vous voulez un rafraîchissement incrémentiel
  CREATE MATERIALIZED VIEW LOG ON Rencontre WITH ROWID;
  
  -- Créer la vue matérialisée pour répliquer les données
  CREATE MATERIALIZED VIEW Rencontre_replica
  REFRESH COMPLETE ON DEMAND
  AS SELECT * FROM Rencontre@lien_vers_orapeda3;
  ```

- **Sur orapeda3** (pour la table Gain, assumant une réplication depuis orapeda2 vers orapeda3) :
  ```sql
  -- Créer un log de modifications sur la table originale si vous voulez un rafraîchissement incrémentiel
  CREATE MATERIALIZED VIEW LOG ON Gain WITH ROWID;
  
  -- Créer la vue matérialisée pour répliquer les données
  CREATE MATERIALIZED VIEW Gain_replica
  REFRESH COMPLETE ON DEMAND
  AS SELECT * FROM Gain@lien_vers_orapeda2;
  ```

4) Pour fragmenter horizontalement la table **Gain** basée sur la localisation des joueurs :

- **À New-York (orapeda2)**, créez un fragment pour les gains des joueurs américains, utilisant le fragment de joueurs stockés à New-York :
  ```sql
  CREATE TABLE Gain_Americains AS 
  SELECT Gain.* 
  FROM Gain JOIN Joueur_Americains ON Gain.nujoueur = Joueur_Americains.nujoueur;
  ```

- **À Lausanne (orapeda3)**, créez un fragment pour les gains des joueurs non-américains, utilisant le fragment de joueurs stockés à Lausanne :
  ```sql
  CREATE TABLE Gain_ResteDuMonde AS 
  SELECT Gain.* 
  FROM Gain JOIN Joueur_ResteDuMonde ON Gain.nujoueur = Joueur_ResteDuMonde.nujoueur;
  ```

Ces requêtes supposent l'existence des tables **Joueur_Americains** et **Joueur_ResteDuMonde** comme préalablement créées lors de la fragmentation horizontale de la table Joueur.

5) Pour la fragmentation verticale de la table **Sponsor** :

- **À Lausanne (orapeda3)**, stockez les informations sur le directeur et l'adresse :
  ```sql
  CREATE TABLE Sponsor_Lausanne AS 
  SELECT nomSponsor, Directeur, Adresse 
  FROM Sponsor;
  ```

- **À New-York (orapeda2)**, stockez les informations sur le chiffre d'affaire :
  ```sql
  CREATE TABLE Sponsor_NewYork AS 
  SELECT nomSponsor, ChiffreAffaire 
  FROM Sponsor;
  ```

Cela crée deux fragments de la table Sponsor, chaque fragment contenant des colonnes spécifiques selon les besoins de chaque site.