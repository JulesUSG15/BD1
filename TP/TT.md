## 1. Créez un lien de base de données dans votre compte ORAPEDA3 vers votre compte ORAPEDA2 :

```sql
CREATE DATABASE LINK ORAPEDA2 USING 'ORAPEDA2';
```


Vous pouvez vérifier les propriétés du lien en consultant la vue USER_DB_LINKS :

```sql
SELECT * FROM USER_DB_LINKS;
```

![](imgTT/1.png)

## 2. Accéder à la structure de votre table dans la base de données ORAPEDA2 :

```sql
DESC MaTableTT@ORAPEDA2;
```

![](imgTT/2.png)

## 3. Accéder de votre compte de la base ORAPEDA3 au contenu de votre table dans la base de données ORAPEDA2 par la commande SELECT de SQL :

```sql
SELECT * FROM MaTable@ORAPEDA2;
```

## 4. Réaliser une jointure de votre table dans ORAPEDA2 avec une table que vous créez dans votre compte de ORAPEDA3 :

```sql
SELECT *
FROM MaTableTT3 A JOIN MaTableTT@orapeda2 B ON A.id3 = B.Colonne1;
```

![](imgTT/4.png)

5° Mettre à jour votre table dans la base de données ORAPEDA2 à partir de votre compte dans ORAPEDA3. Détruire le lien entre les deux bases :

```sql
-- Dans ORAPEDA3
CONNECT username/password@ORAPEDA3;
UPDATE MaTable@ORAPEDA2 SET Colonne2 = 'NouvelleValeur' WHERE Colonne1 = 'Valeur';

-- Destruction du lien
DROP DATABASE LINK ORAPEDA2;
```

6° Rétablir le lien de ORAPEDA3 vers ORAPEDA2. Vérifier que le lien est bien rétabli :

```sql
-- Dans ORAPEDA3
CONNECT username/password@ORAPEDA3;
CREATE DATABASE LINK ORAPEDA2 CONNECT TO username IDENTIFIED BY "nouveau_mot_de_passe" USING 'ORAPEDA2';

-- Vérification
SELECT * FROM MaTable@ORAPEDA2;
```
7°
Voici comment créer les tables `ClientLyon`, `CommandeLyon`, `ClientsParis`, et `CommandesParis` :

Sur ORAPEDA2 :

```sql
-- Dans ORAPEDA2
CONNECT username/password@ORAPEDA2;

-- Création de la table ClientLyon
CREATE TABLE ClientLyon (
    num NUMBER,
    nom VARCHAR2(50),
    prenom VARCHAR2(50),
    adresse VARCHAR2(100),
    ville VARCHAR2(50),
    CA NUMBER,
    TR NUMBER
);

-- Création de la table CommandeLyon
CREATE TABLE CommandeLyon (
    num NUMBER,
    datec DATE,
    numclt NUMBER,
    livraison VARCHAR2(3)
);
```

Sur ORAPEDA3 :

```sql
-- Dans ORAPEDA3
CONNECT username/password@ORAPEDA3;

-- Création de la table ClientsParis
CREATE TABLE ClientsParis (
    num NUMBER,
    nom VARCHAR2(50),
    prenom VARCHAR2(50),
    adresse VARCHAR2(100),
    ville VARCHAR2(50),
    CA NUMBER,
    TR NUMBER
);

-- Création de la table CommandesParis
CREATE TABLE CommandesParis (
    num NUMBER,
    datec DATE,
    numclt NUMBER,
    livraison VARCHAR2(3)
);
```
8°
1. Créer une vue clients sur ORAPEDA3 qui fait l'union des tables clients :

```sql
-- Dans ORAPEDA3
CREATE VIEW clients AS
SELECT * FROM ClientsParis
UNION
SELECT * FROM ClientLyon;
```

2. Créer une vue commandes sur ORAPEDA3 qui fait l'union des tables commandes :

```sql
-- Dans ORAPEDA3
CREATE VIEW commandes AS
SELECT * FROM CommandesParis
UNION
SELECT * FROM CommandeLyon;
```

3. Écrire une procédure stockée qui insère un nouveau client :

```sql
-- Dans ORAPEDA3
CREATE OR REPLACE PROCEDURE inserer_nouveau_client (
    p_num NUMBER,
    p_nom VARCHAR2,
    p_prenom VARCHAR2,
    p_adresse VARCHAR2,
    p_ville VARCHAR2,
    p_CA NUMBER,
    p_TR NUMBER
) AS
BEGIN
    INSERT INTO ClientsParis VALUES (p_num, p_nom, p_prenom, p_adresse, p_ville, p_CA, p_TR);
END;
/
```

4. Écrire une seconde procédure stockée qui insère une nouvelle commande :

```sql
-- Dans ORAPEDA3
CREATE OR REPLACE PROCEDURE inserer_nouvelle_commande (
    p_num NUMBER,
    p_datec DATE,
    p_numclt NUMBER,
    p_livraison VARCHAR2
) AS
BEGIN
    INSERT INTO CommandesParis VALUES (p_num, p_datec, p_numclt, p_livraison);
END;
/
```

5. Peupler les tables clients d'abord, puis les tables commandes des 2 bases à partir de ORAPEDA3 :

```sql
-- Dans ORAPEDA3
EXECUTE inserer_nouveau_client(1, 'Nom1', 'Prenom1', 'Adresse1', 'Paris', 1500, 0.1);
EXECUTE inserer_nouveau_client(2, 'Nom2', 'Prenom2', 'Adresse2', 'Lyon', 2500, 0.2);

EXECUTE inserer_nouvelle_commande(1, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 1, 'oui');
EXECUTE inserer_nouvelle_commande(2, TO_DATE('2023-02-01', 'YYYY-MM-DD'), 2, 'non');
```

6. Vérifier les insertions en interrogeant la vue clients et la table ClientsParis distante :

```sql
-- Dans ORAPEDA3
SELECT * FROM clients;
SELECT * FROM ClientsParis@ORAPEDA2;
```

7. Insérer des clients sur le site de Paris et sur le site de Lyon qui ont le même nom de famille :

```sql
-- Dans ORAPEDA3
EXECUTE inserer_nouveau_client(3, 'Nom3', 'Prenom3', 'Adresse3', 'Paris', 3000, 0.15);
EXECUTE inserer_nouveau_client(4, 'Nom3', 'Prenom4', 'Adresse4', 'Lyon', 3500, 0.25);
```

8. Insérer des clients dont le CA est supérieur à 2000 :

```sql
-- Dans ORAPEDA3
EXECUTE inserer_nouveau_client(5, 'Nom5', 'Prenom5', 'Adresse5', 'Paris', 5000, 0.2);
EXECUTE inserer_nouveau_client(6, 'Nom6', 'Prenom6', 'Adresse6', 'Lyon', 3000, 0.15);
```

9°

1. Créez la table destinée à recevoir les détails du plan d'exécution (si elle n'existe pas déjà) :

```sql
-- Dans ORAPEDA3
CREATE TABLE PLAN_TABLE (
    statement_id VARCHAR2(30),
    timestamp DATE,
    remarks VARCHAR2(80),
    operation VARCHAR2(30),
    options VARCHAR2(30),
    object_node VARCHAR2(128),
    object_owner VARCHAR2(30),
    object_name VARCHAR2(30),
    object_instance NUMBER,
    object_type VARCHAR2(30),
    optimizer VARCHAR2(255),
    search_columns NUMBER,
    id NUMBER,
    parent_id NUMBER,
    position NUMBER,
    cost NUMBER,
    cardinality NUMBER,
    bytes NUMBER,
    other_tag VARCHAR2(255),
    partition_start VARCHAR2(255),
    partition_stop VARCHAR2(255),
    partition_id NUMBER,
    other LONG,
    distribution VARCHAR2(30)
);
```

2. Demandez à Oracle le plan d'exécution pour la requête R1 et stockez-le dans la table PLAN_TABLE :

```sql
-- Dans ORAPEDA3
EXPLAIN PLAN SET STATEMENT_ID = 'R1' FOR
SELECT *
FROM clients c
JOIN commandes cmd ON c.num = cmd.numclt
WHERE c.ville = 'Lyon';
```

3. Interrogez la table PLAN_TABLE pour obtenir un plan d'exécution lisible :

```sql
-- Dans ORAPEDA3
SELECT LPAD(' ', 2 * (LEVEL - 1)) || operation || ' ' || options || ' ' || object_name || ' ' ||
       DECODE(id, 0, 'Cost = ' || position) "Query Plan"
FROM PLAN_TABLE
START WITH id = 0 AND statement_id = 'R1'
CONNECT BY PRIOR id = parent_id AND statement_id = 'R1';
```

4. Demandez à Oracle le plan d'exécution pour la requête R2 et stockez-le dans la table PLAN_TABLE :

   ```sql
   -- Dans ORAPEDA3
   EXPLAIN PLAN SET STATEMENT_ID = 'R2' FOR
   SELECT *
   FROM clients c1
   JOIN clients c2 ON c1.nom = c2.nom
   WHERE c1.ville = 'Paris' AND c2.ville = 'Lyon';
   ```

5. Interrogez la table PLAN_TABLE pour obtenir un plan d'exécution lisible :

```sql
-- Dans ORAPEDA3
SELECT LPAD(' ', 2 * (LEVEL - 1)) || operation || ' ' || options || ' ' || object_name || ' ' ||
       DECODE(id, 0, 'Cost = ' || position) "Query Plan"
FROM PLAN_TABLE
START WITH id = 0 AND statement_id = 'R2'
CONNECT BY PRIOR id = parent_id AND statement_id = 'R2';
```

6. Demandez à Oracle le plan d'exécution pour la requête R3 et stockez-le dans la table PLAN_TABLE :
   
   ```sql
   -- Dans ORAPEDA3
   EXPLAIN PLAN SET STATEMENT_ID = 'R3' FOR
   SELECT *
   FROM commandes cmd
   JOIN clients c ON cmd.numclt = c.num
   WHERE c.ville = 'Lyon' AND cmd.livraison = 'non';
   ```
7. Interrogez la table PLAN_TABLE pour obtenir un plan d'exécution lisible :

```sql
-- Dans ORAPEDA3
SELECT LPAD(' ', 2 * (LEVEL - 1)) || operation || ' ' || options || ' ' || object_name || ' ' ||
       DECODE(id, 0, 'Cost = ' || position) "Query Plan"
FROM PLAN_TABLE
START WITH id = 0 AND statement_id = 'R3'
CONNECT BY PRIOR id = parent_id AND statement_id = 'R3';
```
8. Demandez à Oracle le plan d'exécution pour la requête R3 et stockez-le dans la table PLAN_TABLE :

   ```sql
   -- Dans ORAPEDA3
   EXPLAIN PLAN SET STATEMENT_ID = 'R4' FOR
   SELECT *
   FROM clients
   WHERE ville = 'Lyon' AND CA > 2000;
   ```
8. Interrogez la table PLAN_TABLE pour obtenir un plan d'exécution lisible :

```sql
-- Dans ORAPEDA3
SELECT LPAD(' ', 2 * (LEVEL - 1)) || operation || ' ' || options || ' ' || object_name || ' ' ||
       DECODE(id, 0, 'Cost = ' || position) "Query Plan"
FROM PLAN_TABLE
START WITH id = 0 AND statement_id = 'R4'
CONNECT BY PRIOR id = parent_id AND statement_id = 'R4';
```  
10°
1. **Utiliser la commande COPY TO pour copier sur ORAPEDA2 les clients de Paris qui ont un CA>2000 sur une nouvelle table ClientsParis_CA_sup_2K :**

```sql
-- Dans ORAPEDA3
COPY FROM username/password@ORAPEDA3 TO username/password@ORAPEDA2
CREATE TABLE ClientsParis_CA_sup_2K AS
SELECT * FROM clients
WHERE ville = 'Paris' AND CA > 2000;
```

Puis interroger la nouvelle table créée :

```sql
-- Dans ORAPEDA2
SELECT * FROM ClientsParis_CA_sup_2K;
```

2. **Créer une vue matérialisée sur ORAPEDA3 :**

Pour créer une vue matérialisée sur ORAPEDA3, vous pouvez utiliser la syntaxe suivante :

```sql
-- Dans ORAPEDA3
CREATE MATERIALIZED VIEW mv_commandes_parisiens
REFRESH FORCE ON DEMAND
START WITH SYSDATE
NEXT SYSDATE + 5/(24*60) -- Rafraîchir toutes les 5 minutes
AS
SELECT
    c.num AS client_num,
    c.nom AS client_nom,
    COUNT(cmd.num) AS nombre_commandes
FROM
    clients c
JOIN
    commandes cmd ON c.num = cmd.numclt
WHERE
    c.ville = 'Paris'
GROUP BY
    c.num, c.nom;
```

Puis pour la deuxième vue matérialisée :

```sql
-- Dans ORAPEDA3
CREATE MATERIALIZED VIEW mv_lyonnais_CA_sup_2K
REFRESH FORCE ON DEMAND
START WITH SYSDATE
NEXT SYSDATE + 5/(24*60) -- Rafraîchir toutes les 5 minutes
AS
SELECT
    c.num AS client_num,
    c.nom AS client_nom,
    cmd.*
FROM
    clients c
JOIN
    commandes cmd ON c.num = cmd.numclt
WHERE
    c.ville = 'Lyon' AND c.CA > 2000;
```

Assurez-vous de remplacer "username" et "password" par vos informations d'identification réelles. Ces vues matérialisées seront rafraîchies automatiquement toutes les 5 minutes.

N'oubliez pas de personnaliser ces commandes en fonction de vos besoins spécifiques et des colonnes réelles dans vos tables.