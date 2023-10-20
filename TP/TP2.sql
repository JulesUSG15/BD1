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


