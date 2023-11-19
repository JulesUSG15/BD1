### 1° Créer une table et manipuler des données :

- **Création de la table et insertion de lignes :**
  ```sql
  CREATE TABLE MaTable (id INT PRIMARY KEY, nom VARCHAR(50));
  INSERT INTO MaTable VALUES (1, 'Ligne 1'), (2, 'Ligne 2'), (3, 'Ligne 3');
  SELECT * FROM MaTable;
  ```

- **Modification, suppression et annulation :**
  ```sql
  UPDATE MaTable SET nom = 'Nouveau Nom' WHERE id = 1;
  DELETE FROM MaTable WHERE id = 2;
  ROLLBACK;
  SELECT * FROM MaTable;
  ```

### 2° Valider et annuler des mises à jour :

- **Mises à jour, validation, puis ROLLBACK :**
  ```sql
  INSERT INTO MaTable VALUES (4, 'Ligne 4'), (5, 'Ligne 5');
  UPDATE MaTable SET nom = 'Modifié' WHERE id = 4;
  DELETE FROM MaTable WHERE id = 5;
  COMMIT;
  ROLLBACK;
  ```

### 3° Fermer une transaction avec EXIT ou QUIT :

- **Insérer des lignes et clore avec EXIT/QUIT :**
  ```sql
  INSERT INTO MaTable VALUES (6, 'Ligne 6'), (7, 'Ligne 7');
  EXIT;
  ```

### 4° Fermer brutalement la session et revenir :

- **Fermer brutalement et vérifier la persistance des données :**
  *Les bases de données modernes sont conçues pour gérer cela correctement, mais cela peut dépendre de la base de données spécifique que vous utilisez.*

### 5° Manipuler les données et la structure de la table :

- **Insertions, ajout de colonne et annulation :**
  ```sql
  INSERT INTO MaTable VALUES (8, 'Ligne 8'), (9, 'Ligne 9');
  ALTER TABLE MaTable ADD COLUMN nouvelle_colonne INT;
  ROLLBACK;
  ```

### 6° Conclusion sur les transactions :

- **Qu'est-ce qu'une transaction et comment valider ou annuler :**
  - Une transaction est un ensemble d'instructions SQL formant une unité de travail atomique.
  - Pour valider les changements, vous utilisez la commande `COMMIT`.
  - Pour annuler les changements, vous utilisez la commande `ROLLBACK`.

En résumé, une transaction est un moyen de garantir l'atomicité, la cohérence, l'isolation et la durabilité (ACID) des opérations dans une base de données. Vous pouvez valider les changements avec `COMMIT` ou annuler avec `ROLLBACK`. L'utilisation de ces commandes dépend du succès ou de l'échec des opérations à l'intérieur de la transaction.


### 1° Connexion depuis une autre fenêtre :

- *Se connecter depuis une autre fenêtre :*
  *Cela dépend du système de gestion de base de données que vous utilisez. En général, vous devrez vous reconnecter avec les mêmes identifiants.*

### 2° Insérer des lignes depuis les deux fenêtres :

- *Insérer des lignes depuis les deux fenêtres :*
  *Les modifications faites dans une fenêtre seront visibles dans l'autre après validation avec `COMMIT`.*

### 3° Créer une nouvelle table depuis une fenêtre :

- *Créer une nouvelle table et insérer des lignes :*
  ```sql
  -- Dans une fenêtre
  CREATE TABLE NouvelleTable (id INT PRIMARY KEY, nom VARCHAR(50));
  INSERT INTO NouvelleTable VALUES (1, 'Nouvelle Ligne 1'), (2, 'Nouvelle Ligne 2');
  ```
  *Les changements dans une fenêtre ne sont pas visibles dans l'autre jusqu'à ce que la transaction soit validée.*

### 4° Détruire la nouvelle table :

- *Détruire la nouvelle table :*
  ```sql
  -- Dans la même fenêtre
  DROP TABLE NouvelleTable;
  ```
  *La table sera détruite et les changements seront visibles dans l'autre fenêtre après validation.*

### 5° Ajouter une clé à la table et tester le ROLLBACK :

- *Ajouter une clé et tester le ROLLBACK :*
  ```sql
  -- Dans la même fenêtre
  ALTER TABLE MaTable ADD COLUMN cle INT;
  UPDATE MaTable SET cle = 1 WHERE id = 1;
  -- Essayer d'insérer une ligne avec la même valeur de clé depuis l'autre fenêtre
  -- ROLLBACK dans l'autre fenêtre
  ```

### 6° Fermer la session dans la fenêtre d'insertion :

- *Fermer la session avec EXIT ou QUIT :*
  *Les mises à jour dans la fenêtre fermée resteront en attente jusqu'à ce qu'elles soient validées ou annulées dans la fenêtre restante.*

### 7° Ouvrir une nouvelle session :

- *Ouvrir une nouvelle session et vérifier la dernière transaction :*
  *Les changements devraient être visibles dans la nouvelle session après validation.*

### 8° Insérer une ligne, créer une nouvelle table et ROLLBACK :

- *Insérer une ligne, créer une nouvelle table et ROLLBACK :*
  ```sql
  -- Dans la même fenêtre
  INSERT INTO MaTable VALUES (10, 'Ligne 10');
  CREATE TABLE NouvelleTable (id INT PRIMARY KEY, nom VARCHAR(50));
  INSERT INTO NouvelleTable VALUES (1, 'Ligne Nouvelle');
  -- ROLLBACK
  ```

### 9° Insérer une ligne, éliminer une table et ROLLBACK :

- *Insérer une ligne, éliminer une table et ROLLBACK :*
  ```sql
  -- Dans la même fenêtre
  INSERT INTO MaTable VALUES (11, 'Ligne 11');
  DROP TABLE NouvelleTable;
  -- ROLLBACK
  ```
  *La dernière ligne insérée ne sera pas affectée par le ROLLBACK, mais la table supprimée sera restaurée.*


### 1° Accorder le droit SELECT à l'autre groupe :

- *Accorder le droit SELECT à l'autre groupe :*
  ```sql
  -- Dans le groupe 1
  GRANT SELECT ON MaTable TO groupe2;
  ```
  *Vérifier le privilège accordé :*
  ```sql
  SELECT * FROM ALL_TAB_PRIVS WHERE table_name = 'MaTable';
  ```

### 2° Observer les mises à jour de l'autre groupe :

- *Observer les mises à jour de l'autre groupe :*
  *Les membres du groupe 2 peuvent effectuer des mises à jour sur leur table, mais le groupe 1 ne voit pas ces mises à jour sans le droit correspondant.*

### 3° Essayer d'insérer une ligne dans la table de l'autre groupe :

- *Essayer d'insérer une ligne sans le droit INSERT :*
  ```sql
  -- Dans le groupe 1
  INSERT INTO groupe2.MaTable VALUES (1, 'Nouvelle Ligne');
  ```
  *Cela devrait générer une erreur car le groupe 1 n'a pas le droit d'INSERT.*

### 4° Accorder le droit INSERT par l'autre groupe :

- *Accorder le droit INSERT par l'autre groupe :*
  ```sql
  -- Dans le groupe 2
  GRANT INSERT ON MaTable TO groupe1;
  ```
  *Reprendre l'insertion :*
  ```sql
  -- Dans le groupe 1
  INSERT INTO groupe2.MaTable VALUES (1, 'Nouvelle Ligne');
  ```

### 5° Réaliser une jointure entre les tables des deux groupes :

- *Réaliser une jointure entre les tables des deux groupes :*
  ```sql
  -- Dans le groupe 1
  SELECT * FROM MaTable JOIN groupe2.MaTable ON MaTable.id = groupe2.MaTable.id;
  ```

Ces étapes illustrent comment accorder des droits SELECT et INSERT entre deux groupes dans une base de données, ainsi que comment vérifier les privilèges accordés. Les jointures entre les tables de différents groupes sont également possibles avec les droits appropriés.


### 1. Copier les tables dans votre compte :

```sql
CREATE TABLE Dept AS SELECT * FROM Scott.Dept;
CREATE TABLE Emp AS SELECT * FROM Scott.Emp;
CREATE TABLE Salgrade AS SELECT * FROM Scott.Salgrade;
```

### 2. Requêtes SQL :

a. **Employés dirigés par 'King' :**
```sql
SELECT EName FROM Emp WHERE Mgr = (SELECT EmpNo FROM Emp WHERE EName = 'King');
```

b. **Employés dépendant de 'Jones' :**
```sql
SELECT EName FROM Emp START WITH EName = 'Jones' CONNECT BY PRIOR EmpNo = Mgr;
```

c. **Employés dont dépend 'Jones' :**
```sql
SELECT EName FROM Emp START WITH Mgr = (SELECT EmpNo FROM Emp WHERE EName = 'Jones') CONNECT BY PRIOR EmpNo = Mgr;
```

d. **Employés dépendant de 'Blake', sauf 'Blake' lui-même :**
```sql
SELECT EName FROM Emp WHERE Mgr = (SELECT EmpNo FROM Emp WHERE EName = 'Blake') AND EmpNo != (SELECT EmpNo FROM Emp WHERE EName = 'Blake');
```

e. **Employés dépendant de 'King' sauf ceux dépendant de 'Blake' :**
```sql
SELECT EName FROM Emp 
WHERE Mgr IN (SELECT EmpNo FROM Emp WHERE EName = 'King') 
AND Mgr NOT IN (SELECT EmpNo FROM Emp WHERE EName = 'Blake');
```

### 3. Fonction PL/SQL pour le nombre d'employés par département :

```sql
CREATE OR REPLACE FUNCTION GetEmpCount(p_deptno Emp.DeptNo%TYPE) RETURN NUMBER
IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM Emp WHERE DeptNo = p_deptno;
  RETURN v_count;
END;
/

-- Appeler la fonction dans un bloc PL/SQL
DECLARE
  v_result NUMBER;
BEGIN
  v_result := GetEmpCount(20); -- Exemple avec le département 20
  DBMS_OUTPUT.PUT_LINE('Nombre d''employés : ' || v_result);
END;
/

### 4. Ajouter la colonne NbEmps à la table Dept :

a. **En utilisant la fonction stockée :**
```sql
ALTER TABLE Dept ADD NbEmps NUMBER;

UPDATE Dept d
SET d.NbEmps = GetEmpCount(d.DeptNo);
```

b. **En utilisant un curseur :**
```sql
ALTER TABLE Dept ADD NbEmps NUMBER;

DECLARE
  CURSOR C1 IS SELECT DeptNo FROM Dept;
  v_count NUMBER;
BEGIN
  FOR C1_enr IN C1 LOOP
    v_count := GetEmpCount(C1_enr.DeptNo);
    UPDATE Dept SET NbEmps = v_count WHERE DeptNo = C1_enr.DeptNo;
  END LOOP;
END;
/

### 5. Déclencheur pour mettre à jour le nombre d'employés :

```sql
CREATE OR REPLACE TRIGGER UpdateEmpCount
AFTER INSERT OR DELETE OR UPDATE OF DeptNo ON Emp
FOR EACH ROW
BEGIN
  UPDATE Dept SET NbEmps = GetEmpCount(:NEW.DeptNo) WHERE DeptNo = :NEW.DeptNo;
END;
/

### 6. Procédure pour mettre à jour le département de toute une équipe :

```sql
CREATE OR REPLACE PROCEDURE UpdateTeamDept(p_empno Emp.EmpNo%TYPE, p_new_deptno Dept.DeptNo%TYPE)
IS
BEGIN
  -- Mettre à jour le département de toute l'équipe
  UPDATE Emp SET DeptNo = p_new_deptno
  WHERE EmpNo IN (SELECT EmpNo FROM Emp START WITH EmpNo = p_empno CONNECT BY PRIOR EmpNo = Mgr);
END;
/
```