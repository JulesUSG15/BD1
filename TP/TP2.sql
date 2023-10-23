CREATE TABLE Commandes (
 NoCom	NUMBER(5),
  	Client      	VARCHAR2(20),
  	Appellation 	VARCHAR2(20),
  	NomFour     	VARCHAR2(20),
  	Qte         	NUMBER(4)
  );

CREATE TABLE Produits (
  	Appellation VARCHAR(255),
  	NomFour VARCHAR(255),
  	Prix DECIMAL(10,2)
);

CREATE TABLE Fournisseurs1 (
  	NomFour VARCHAR(255),
  	Statut VARCHAR(255),
  	Ville VARCHAR(255)
);

/* Modifier la table fournisseurs pour ajouter la contrainte de clé primaire sur
le nom du fournisseur */

ALTER TABLE Fournisseurs1
ADD CONSTRAINT PK_Fournisseurs1 PRIMARY KEY (NomFour);

/* Modifier la table produits pour ajouter la contrainte de clé primaire sur le
l’appellation et le nom du fournisseur */

ALTER TABLE Produits
ADD CONSTRAINT PK_Produits PRIMARY KEY (Appellation, NomFour);

/* Modifier la table commandes pour ajouter la contrainte de clé primaire sur
le numéro de commande */

ALTER TABLE Commandes
ADD CONSTRAINT PK_Commandes PRIMARY KEY (NoCom);

/* Modifier la table produits pour ajouter la contrainte de clé étrangère sur la
table fournisseurs */

ALTER TABLE Produits
ADD CONSTRAINT FK_Produits_Fournisseurs1 FOREIGN KEY (NomFour) REFERENCES Fournisseurs1(NomFour);

/* Modifier la table commandes pour ajouter la contrainte de clé étrangère sur
la table produits */

ALTER TABLE Commandes
ADD CONSTRAINT FK_Commandes_Produits FOREIGN KEY (Appellation, NomFour) REFERENCES Produits(Appellation, NomFour);

/*Assurez-vous que les contraintes d’intégrité de clé primaire et de clé étrangère sont
bien créées. Pour cela, consultez le dictionnaire pour voir vos contraintes.*/

SELECT * FROM USER_CONSTRAINTS;

/* Ajouter le fournisseur : (‘BonPom’ , ‘EARL’, ‘Bordeaux’)
Que se passe t-il ? Pourquoi ? */

INSERT INTO Fournisseurs1 VALUES ('BonPom', 'EARL', 'Bordeaux');

/* Erreur commençant à la ligne: 1 de la commande -
INSERT INTO Fournisseurs1 VALUES ('BonPom', 'EARL', 'Bordeaux')
Rapport d'erreur -
ORA-00001: violation de contrainte unique (INI3A02.PK_FOURNISSEURS1) */

/* Ajouter le fournisseur : (‘PomBon’ , ‘SARL’, ‘Dijon’)
Que se passe t-il ? Pourquoi ? */

INSERT INTO Fournisseurs1 VALUES ('PomBon', 'SARL', 'Dijon');

/* 1 ligne inséré. */

/* Supprimer le fournisseur : (‘BonPom’ , ‘SARL’, ‘Dijon’)
Que se passe t-il ? Pourquoi ? */ 

DELETE FROM Fournisseurs1 WHERE NomFour = 'BonPom' AND Statut = 'SARL' AND Ville = 'Dijon';

/* Erreur commençant à la ligne: 1 de la commande -
DELETE FROM Fournisseurs1 WHERE NomFour = 'BonPom' AND Statut = 'SARL' AND Ville = 'Dijon'
Rapport d'erreur -
ORA-02292: violation de contrainte (INI3A02.FK_PRODUITS_FOURNISSEURS1) d'intégrité - enregistrement fils existant */

/* Ajouter le produit : (‘Agata , ‘Charlie’, ‘20’)
Que se passe t-il ? Pourquoi ? */

INSERT INTO Produits VALUES ('Agata', 'Charlie', 20);

/* Erreur commençant à la ligne: 1 de la commande -
INSERT INTO Produits VALUES ('Agata', 'Charlie', 20)
Rapport d'erreur -
ORA-00001: violation de contrainte unique (INI3A02.PK_PRODUITS) */

/* Ajouter le produit : (‘Agata’ , ‘LesPommeDeToto’, ‘Belleville’)
Que se passe t-il ? Pourquoi ? */

INSERT INTO Produits VALUES ('Agata', 'LesPommeDeToto', 20);

/* Erreur commençant à la ligne: 1 de la commande -
INSERT INTO Produits VALUES ('Agata', 'LesPommeDeToto', 20)
Rapport d'erreur -
ORA-02291: violation de contrainte d'intégrité (INI3A02.FK_PRODUITS_FOURNISSEURS1) - clé parent introuvable */

/* Ajouter la commande : (2345, ‘Florent’, ‘Amandine, ‘Vincent’)
Que se passe t-il ? Pourquoi ? */

INSERT INTO Commandes VALUES (2345, 'Florent', 'Amandine', 'Vincent');

/* Erreur commençant à la ligne: 1 de la commande -
INSERT INTO Commandes VALUES (2345, 'Florent', 'Amandine', 'Vincent')
Erreur à la ligne de commande: 1 Colonne: 13
Rapport d'erreur -
Erreur SQL : ORA-00947: nombre de valeurs insuffisant
00947. 00000 -  "not enough values"
*Cause:    
*Action:
*/

/* Exercice 2 */

-- 1
-- Supprimer toutes les tables de votre compte
BEGIN
  FOR cur_rec IN (SELECT object_name, object_type FROM user_objects WHERE object_type IN ('TABLE'))
  LOOP
    EXECUTE IMMEDIATE 'DROP ' || cur_rec.object_type || ' "' || cur_rec.object_name || '"';
  END LOOP;
END;

-- Supprimer toutes les vues de votre compte
BEGIN
  FOR cur_rec IN (SELECT object_name, object_type FROM user_objects WHERE object_type IN ('VIEW'))
  LOOP
    EXECUTE IMMEDIATE 'DROP ' || cur_rec.object_type || ' "' || cur_rec.object_name || '"';
  END LOOP;
END;

-- Vérifier que toutes les tables ont été supprimées
SELECT * FROM USER_TABLES;

-- Vérifier que toutes les vues ont été supprimées
SELECT * FROM USER_VIEWS;

DESC MaTable;

-- 2
-- Nombre total d'objets accessibles à votre compte
SELECT COUNT(*) AS "Nombre total d'objets accessibles à votre compte" FROM ALL_OBJECTS;

-- Nombre d'objets pour chaque type d'objet
SELECT OBJECT_TYPE, COUNT(*) AS "Nombre d'objets" FROM ALL_OBJECTS GROUP BY OBJECT_TYPE;

-- Nombre d'objets du dictionnaire de données (de propriétaire SYS)
SELECT COUNT(*) AS "Nombre d'objets du dictionnaire de données" FROM ALL_OBJECTS WHERE OWNER = 'SYS';

-- Nombre d'objets par type d'objet de ce dictionnaire des données
SELECT OBJECT_TYPE, COUNT(*) AS "Nombre d'objets" FROM ALL_OBJECTS WHERE OWNER = 'SYS' GROUP BY OBJECT_TYPE;

-- Nombre d'objets par type du compte Cirque (ou CIRQUE)
SELECT OWNER, OBJECT_TYPE, COUNT(*) AS "Nombre d'objets" FROM ALL_OBJECTS WHERE OWNER = 'CIRQUE' OR OWNER = 'CIRQUE' GROUP BY OWNER, OBJECT_TYPE;

-- Visualiser les tables de Cirque à partir de ALL_TABLES
SELECT * FROM ALL_TABLES WHERE OWNER = 'CIRQUE';

-- Visualiser les vues de Cirque à partir de ALL_VIEWS
SELECT * FROM ALL_VIEWS WHERE OWNER = 'CIRQUE';

-- 3
SELECT c.OWNER, c.TABLE_NAME, c.CONSTRAINT_NAME, c.CONSTRAINT_TYPE, c.R_CONSTRAINT_NAME, c.DELETE_RULE, c.SEARCH_CONDITION, cc.COLUMN_NAME, cc.POSITION
FROM ALL_CONSTRAINTS c
JOIN ALL_CONS_COLUMNS cc ON c.OWNER = cc.OWNER AND c.CONSTRAINT_NAME = cc.CONSTRAINT_NAME
WHERE c.OWNER = 'CIRQUE';

-- 4

-- 5
SELECT c.OWNER, c.TABLE_NAME, c.CONSTRAINT_NAME, c.CONSTRAINT_TYPE, c.R_CONSTRAINT_NAME, c.DELETE_RULE, c.SEARCH_CONDITION, cc.COLUMN_NAME, cc.POSITION
FROM ALL_CONSTRAINTS c
JOIN ALL_CONS_COLUMNS cc ON c.OWNER = cc.OWNER AND c.CONSTRAINT_NAME = cc.CONSTRAINT_NAME
WHERE c.OWNER = 'CIRQUE' AND (c.TABLE_NAME = 'ACCESSOIRES1' OR c.TABLE_NAME = 'RANGEMENT')
AND cc.COLUMN_NAME IN ('ACCESSOIRE', 'COULEUR', 'NOCAMION');

-- 6
-- Création de la table Personnel
CREATE TABLE Personnel AS SELECT * FROM Cirque.Personnel;

-- Création de la table Numéros
CREATE TABLE Numéros AS SELECT * FROM Cirque.Numéros;

-- Création de la table Accessoires
CREATE TABLE Accessoires AS SELECT * FROM Cirque.Accessoires;

-- Création de la table Utilisation
CREATE TABLE Utilisation AS SELECT * FROM Cirque.Utilisation;

-- 7

-- 8
-- Création de la contrainte NOT NULL sur NoCamion
ALTER TABLE Accessoires ADD CONSTRAINT Accessoires_NoCamion_nn NOT NULL (NoCamion);

-- Création de la contrainte CHECK sur NoCamion
ALTER TABLE Accessoires ADD CONSTRAINT Accessoires_NoCamion_ck CHECK (NoCamion IS NOT NULL);

-- Création de la deuxième contrainte CHECK sur NoCamion
ALTER TABLE Accessoires ADD CONSTRAINT Accessoires_NoCamion_ck2 CHECK (NoCamion IS NOT NULL);

-- Création de la contrainte CHECK sur NoRatelier
ALTER TABLE Accessoires ADD CONSTRAINT Accessoires_NoRatelier_ck CHECK (NoRatelier IS NOT NULL);

SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = 'ACCESSOIRES';

-- Suppression de la contrainte NOT NULL sur NoCamion
ALTER TABLE Accessoires DROP CONSTRAINT Accessoires_NoCamion_nn;

-- Suppression de la contrainte CHECK sur NoCamion
ALTER TABLE Accessoires DROP CONSTRAINT Accessoires_NoCamion_ck;

-- Suppression de la deuxième contrainte CHECK sur NoCamion
ALTER TABLE Accessoires DROP CONSTRAINT Accessoires_NoCamion_ck2;

-- Suppression de la contrainte CHECK sur NoRatelier
ALTER TABLE Accessoires DROP CONSTRAINT Accessoires_NoRatelier_ck;

-- 9
-- Recréation de la contrainte PRIMARY KEY sur Personnel
ALTER TABLE Personnel ADD CONSTRAINT PK_Personnel PRIMARY KEY (NoPersonnel);

-- Recréation de la contrainte PRIMARY KEY sur Numéros
ALTER TABLE Numéros ADD CONSTRAINT PK_Numéros PRIMARY KEY (TitreDeNuméro);

-- Recréation de la contrainte PRIMARY KEY sur Utilisation
ALTER TABLE Utilisation ADD CONSTRAINT PK_Utilisation PRIMARY KEY (NoPersonnel, TitreDeNuméro);

-- Recréation de la contrainte référentielle Utilisateur Í1 Nom
ALTER TABLE Personnel ADD CONSTRAINT Personnel_Utilisateur_fk FOREIGN KEY (Nom) REFERENCES Utilisateur(Nom);

-- Recréation de la contrainte référentielle Responsable Í2 Nom
ALTER TABLE Personnel ADD CONSTRAINT Personnel_Responsable_fk FOREIGN KEY (Responsable) REFERENCES Responsable(Nom);

-- Recréation de la contrainte référentielle Utilisation.TitreDeNuméro Í3 Numéros.TitreDeNuméro
ALTER TABLE Utilisation ADD CONSTRAINT Utilisation_Numéros_fk FOREIGN KEY (TitreDeNuméro) REFERENCES Numéros(TitreDeNuméro);

SELECT * FROM USER_INDEXES WHERE TABLE_NAME IN ('PERSONNEL', 'NUMÉROS', 'UTILISATION');

SELECT * FROM USER_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'R' AND TABLE_NAME IN ('PERSONNEL', 'UTILISATION') AND (R_CONSTRAINT_NAME = 'UTILISATION_NUMÉROS_FK' OR R_CONSTRAINT_NAME = 'PERSONNEL_UTILISATEUR_FK' OR R_CONSTRAINT_NAME = 'PERSONNEL_RESPONSABLE_FK');

-- 10
-- Création de la clé UNIQUE sur Accessoires.Accessoire
ALTER TABLE Accessoires ADD CONSTRAINT Accessoires_Accessoire_uk UNIQUE (Accessoire);

-- Création de la contrainte référentielle Utilisation.Accessoire Í4 Accessoires.Accessoire
ALTER TABLE Utilisation ADD CONSTRAINT Utilisation_Accessoires_fk FOREIGN KEY (Accessoire) REFERENCES Accessoires(Accessoire);

SELECT * FROM USER_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'R' AND TABLE_NAME IN ('UTILISATION') AND R_CONSTRAINT_NAME = 'UTILISATION_ACCESSOIRES_FK';

SELECT * FROM USER_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'U' AND TABLE_NAME IN ('ACCESSOIRES') AND CONSTRAINT_NAME = 'ACCESSOIRES_ACCESSOIRE_UK';

-- 11
-- Désactivation de la contrainte référentielle Utilisation.Accessoire Í4 Accessoires.Accessoire
ALTER TABLE Utilisation DISABLE CONSTRAINT Utilisation_Accessoires_fk;

-- Réactivation de la contrainte référentielle Utilisation.Accessoire Í4 Accessoires.Accessoire
ALTER TABLE Utilisation ENABLE CONSTRAINT Utilisation_Accessoires_fk;

-- 12
-- Création de la table Exceptions pour lister les violations de la contrainte
CREATE TABLE Exceptions (ROW_ID ROWID, OWNER VARCHAR2(30), TABLE_NAME VARCHAR2(30), CONSTRAINT_NAME VARCHAR2(30));

-- Activation de la contrainte référentielle Utilisation.Accessoire Í4 Accessoires.Accessoire avec la clause EXCEPTIONS
ALTER TABLE Utilisation ADD CONSTRAINT rUtilisation_Access FOREIGN KEY (Accessoire) REFERENCES Accessoires(Accessoire) EXCEPTIONS INTO Exceptions;

-- Sélection des lignes de la table référençante violant la contrainte
SELECT * FROM Exceptions WHERE CONSTRAINT_NAME = 'RUTILISATION_ACCESS';

-- 13
-- Insertion de la ligne ('étrier', ' ', NULL, 0.2, 0) dans Accessoires
INSERT INTO Accessoires (Accessoire, NoCamion, NoRatelier, Prix, Quantité) VALUES ('étrier', ' ', NULL, 0.2, 0);

-- Création de la contrainte référentielle Utilisation.Accessoire Í4 Accessoires.Accessoire
ALTER TABLE Utilisation ADD CONSTRAINT Utilisation_Accessoires_fk FOREIGN KEY (Accessoire) REFERENCES Accessoires(Accessoire);
