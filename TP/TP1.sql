/* Exercice 1 */
/* Céation des tables */
CREATE TABLE Commandes (
    NoCom	NUMBER(5),
  	Client      	VARCHAR2(20),
  	Appellation 	VARCHAR2(20),
  	NomFour     	VARCHAR2(20),
  	Qte         	NUMBER(4)
  );
INSERT INTO Commandes VALUES (1535,'Jean', 'Agata', 'BonPom', 6) ;
INSERT INTO Commandes VALUES (1854,'Jean', 'Agata', 'Vincent', 20) ;
INSERT INTO Commandes VALUES (1254,'Paul','Jeannette','Charlie', 20) ;
INSERT INTO Commandes VALUES (1258,'Paul','Jeannette','Charlie', 20) ;
INSERT INTO Commandes VALUES (1596,'Paul','Amandine','Charlie', 12) ;
INSERT INTO Commandes VALUES (2000,'Jean', 'Agata', 'BonPom', 12) ;

SELECT table_name
FROM USER_TABLES
WHERE table_name = 'COMMANDES';
DESC COMMANDES;
SELECT COUNT(*)
FROM COMMANDES;

CREATE TABLE Produits (
  	Appellation VARCHAR(255),
  	NomFour VARCHAR(255),
  	Prix DECIMAL(10,2)
);
INSERT INTO Produits VALUES('Agata', 'BonPom', 20);
INSERT INTO Produits VALUES('Amandine', 'Charlie', 18);
INSERT INTO Produits VALUES('Agata', 'Vincent', 8.2);
INSERT INTO Produits VALUES('Monalisa', 'Vincent', 4.3);
INSERT INTO Produits VALUES('Agata', 'Charlie', 18.5);
INSERT INTO Produits VALUES('Bintje', 'Charlie', 5.1);
INSERT INTO Produits VALUES('Jeannette', 'Charlie', 5);
INSERT INTO Produits VALUES('Agata', 'SaV', 10);

SELECT table_name
FROM USER_TABLES
WHERE table_name = 'PRODUITS';
DESC PRODUITS;
SELECT COUNT(*)
FROM PRODUITS;

CREATE TABLE Fournisseurs1 (
  	NomFour VARCHAR(255),
  	Statut VARCHAR(255),
  	Ville VARCHAR(255)
);
INSERT INTO Fournisseurs1 VALUES('BonPom', 'SARL', 'Dijon');
INSERT INTO Fournisseurs1 VALUES('Charlie', 'SA', 'Dijon');
INSERT INTO Fournisseurs1 VALUES('Vincent', 'SA', 'Valence');
INSERT INTO Fournisseurs1 VALUES('SaV', 'Association', 'Antraigues');

SELECT table_name
FROM USER_TABLES
WHERE table_name = 'FOURNISSEURS1';
DESC FOURNISSEURS1;
SELECT COUNT(*)
FROM FOURNISSEURS1;

/* Donner les commandes*/
SELECT *
FROM Commandes ;

/*Donner les appellations commandées */
SELECT DISTINCT Appellation
FROM Commandes ;

/*Donner les appellations commandées par Jean */
SELECT DISTINCT Appellation
FROM Commandes
WHERE Client = 'Jean' ;

/* Donner les fournisseurs de Agata ou de Amandine à un prix inférieur à 10 euros */
SELECT DISTINCT NomFour
FROM Produits
WHERE Appellation = ('Agata' OR Appellation = 'Amandine') AND Prix < 10 ;

/* Donner les produits commandés par Jean */
SELECT P.*
FROM Produits P 
JOIN Commandes C ON P.Appellation = C.Appellation AND P.NomFour = C.NomFour
WHERE C.Client = 'Jean';

/* Quelles sont les paires de fournisseurs qui habitent dans une même ville ? */
SELECT DISTINCT F1.NomFour AS Fournisseur1, F2.NomFour AS Fournisseur2, F1.Ville
FROM Fournisseurs1 F1
JOIN Fournisseurs1 F2 ON F1.Ville = F2.Ville
WHERE F1.NomFour < F2.NomFour;

/* Quels sont les produits qui coûtent plus de 15 euros ou qui sont commandés par Jean ? */
SELECT DISTINCT p.*
FROM Produits p
JOIN Commandes c ON p.Appellation = c.Appellation
WHERE p.Prix > 15 OR c.Client = 'Jean';

/* Quels sont les produits qui n’ont pas été commandés ? */
SELECT *
FROM Produits
WHERE (Appellation, NomFour) NOT IN (
    SELECT Appellation, NomFour
    FROM Commandes
);

/* Quels sont les produits commandés en quantité supérieure à 10 et dont le prix est inférieur à 15 ? */
SELECT *
FROM Produits
WHERE Prix < 15 AND (Appellation, NomFour) IN (
    SELECT Appellation, NomFour
    FROM Commandes
    GROUP BY (Appellation, NomFour)
    HAVING SUM(Qte) > 10
);

/* Quelles sont les appellations qui sont fournies par tous les fournisseurs ? */
SELECT Appellation
FROM Produits
GROUP BY Appellation
HAVING COUNT(DISTINCT NomFour) = (SELECT COUNT(*) FROM Fournisseurs1);

/* Exercice 2 */
/* Création des tables */
CREATE TABLE Joueur AS SELECT * FROM BDRENS.joueur;
CREATE TABLE Rencontre AS SELECT * FROM BDRENS.rencontre;
CREATE TABLE Gain AS SELECT * FROM BDRENS.gain;

/* Création des vues */
/* Création d’une vue JoueurFR(NuJoueur, Prenom, Nom)*/
CREATE VIEW JoueurFR AS
SELECT NuJoueur, Prenom, Nom
FROM Joueur
WHERE Nationalite = 'France';

SELECT * FROM JoueurFR;

/*Création d’une vue JoueurFRsponPEUG(NuJoueur, PrenomNom)*/ 
CREATE VIEW JoueurFRsponPEUG AS
SELECT DISTINCT J.NuJoueur, J.Prenom || ' ' || J.Nom AS PrenomNom
FROM Joueur J
JOIN Gain G ON J.NuJoueur = G.NuJoueur
WHERE J.Nationalite = 'France' AND G.NomSponsor = 'Peugeot';

SELECT * FROM JoueurFRsponPEUG; 

/*Création d’une vue PrimeJoueurFRsponPEUG(NuJoeur, SPrime)*/
CREATE VIEW PrimeJoueurFRsponPEUG AS
SELECT J.NuJoueur, J.Nom, SUM(G.Prime) AS SPrime
FROM Joueur J
JOIN Gain G ON J.NuJoueur = G.NuJoueur
WHERE J.Nationalite = 'France' AND G.NomSponsor = 'Peugeot'
GROUP BY J.NuJoueur, J.Nom;

SELECT * FROM PrimeJoueurFRsponPEUG;

/*Création d’une vue RencGagneeJoueurFRriche(NuGagnant, NuPerdant, LieuTournoi, Annee, Score)*/
CREATE VIEW RencGagneeJoueurFRriche AS
SELECT R.NuGagnant, R.NuPerdant, R.LieuTournoi, R.Annee
FROM Rencontre R
JOIN (
    SELECT J.NuJoueur
    FROM Joueur J
    JOIN Gain G ON J.NuJoueur = G.NuJoueur
    WHERE J.Nationalite = 'France'
    GROUP BY J.NuJoueur
    HAVING SUM(G.Prime) > 1000000 
) RicheJoueurs ON R.NuGagnant = RicheJoueurs.NuJoueur;

SELECT * FROM RencGagneeJoueurFRriche;

/* Interrogations des tables */
/*Afficher le contenu des tables JOUEUR, GAIN et RENCONTRE.*/
SELECT * FROM Rencontre;
SELECT * FROM Joueur;
SELECT * FROM Gain;

/*Numéro et tournoi d’engagement (lieu et année) des joueurs sponsorisés par Peugeot entre 1990 et 1994.*/
SELECT NuJoueur, LieuTournoi, Annee
FROM Gain
WHERE NomSponsor = 'Peugeot' AND 1990 <= Annee AND Annee <= 1994;

/*Nom et année de naissance des joueurs ayant participé au tournoi de Roland Garros en 1994.*/
SELECT J.nom, J.anNais
FROM Joueur J JOIN Gain G ON J.nuJoueur = G.nuJoueur
WHERE G.lieuTournoi = 'Roland Garros' AND G.annee = 1994;

/*Nom et nationalité des joueurs sponsorisés par Peugeot et ayant gagné à Roland Garros au moins un match.*/
SELECT DISTINCT J.nom, J.nationalite
FROM Joueur J
    JOIN Rencontre R ON J.nuJoueur = R.nuGagnant
    JOIN Gain G ON R.nuGagnant = G.nuJoueur
WHERE G.lieuTournoi = 'Roland Garros' AND nomSponsor = 'Peugeot';

/*Nom et nationalité des joueurs ayant participé à la fois au tournoi de Roland Garros et à celui de Wimbledon, en 1992.*/
	SELECT J.nom, J.nationalite
FROM Joueur J JOIN Gain G ON J.nuJoueur = G.nuJoueur
WHERE G.lieuTournoi = 'Roland Garros'
    AND annee = 1992
    AND J.nuJoueur IN (
        SELECT J.nuJoueur
        FROM Joueur J JOIN Gain G ON J.nuJoueur = G.nuJoueur
        WHERE G.lieuTournoi = 'Wimbledon' AND annee = 1992
    );

/*Nombre de joueurs ayant participé au tournoi de Wimbledon en 1993.*/
SELECT COUNT(*)
FROM Gain
WHERE lieuTournoi ='Wimbledon' AND annee = 1993;

/*Moyenne des primes gagnées par année.*/
SELECT annee, ROUND(AVG(prime), 2)
FROM Gain
GROUP BY annee;

/*Nom des joueurs ayant toutes leurs primes à Roland Garros supérieures à 1M€.*/
SELECT J.nom
FROM Joueur J JOIN Gain G ON J.nuJoueur = G.nuJoueur
WHERE G.lieuTournoi = 'Roland Garros'
GROUP BY (J.nuJoueur, J.nom)
HAVING MIN(G.prime) > 1000000;

/*Nom des joueurs ayant toujours perdu à Wimbledon et toujours gagné à Roland Garros.*/
SELECT nom
FROM Joueur J JOIN Gain G ON J.nuJoueur = G.nuJoueur
WHERE G.lieuTournoi = 'Roland Garros' AND J.nuJoueur NOT IN (
    SELECT nuPerdant
    FROM Rencontre
    WHERE lieuTournoi = 'Roland Garros'
)
INTERSECT
SELECT nom
FROM Joueur J JOIN Gain G ON J.nuJoueur = G.nuJoueur
WHERE G.lieuTournoi = 'Wimbledon' AND J.nuJoueur NOT IN (
    SELECT nuGagnant
    FROM Rencontre
    WHERE lieuTournoi = 'Wimbledon'
);

/*Noms des joueurs ayant participé à tous les tournois de Roland Garros.*/
SELECT nom
FROM Joueur J JOIN Gain G ON J.nuJoueur = G.nuJoueur
WHERE lieuTournoi = 'Roland Garros'
GROUP BY nom
HAVING COUNT(annee) = (
    SELECT COUNT(DISTINCT annee)
    FROM Gain
    where lieuTournoi = 'Roland Garros'
);

/*Valeur de la plus forte prime attribuée lors d'un tournoi en 1992, et noms des joueurs qui l'ont touchée.*/
SELECT nom
FROM Joueur J JOIN Gain G ON J.nuJoueur = G.nuJoueur
WHERE annee = 1992
GROUP BY nom
HAVING MAX(prime) = (
    SELECT MAX(prime)
    FROM Gain
    WHERE annee = 1992
);

/*Noms des sponsors représentés à tous les tournois.*/
SELECT nomSponsor
FROM (
    SELECT DISTINCT nomSponsor, lieuTournoi, annee
    FROM Gain
)
GROUP BY nomSponsor
HAVING COUNT(*) = (
    SELECT COUNT(*)
    FROM (
        SELECT DISTINCT lieuTournoi, annee
        FROM Gain
    )
);