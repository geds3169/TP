<h1 align="center"> TP Final</h1>    

<h3 align="center">odoo K8s avec édition des différents manifestes</h3> 

<h3 align="center">==========================================</h3>  
  
## **La mise en place de ce TP est faisable de deux façon:**

1. lancer les fichiers un à un de façon méthodique et logique
  
2. lancer l'ensemble des fichiers via en lui indiquant, de traiter l'ensemble des fichiers yaml.
  

---

## Prèsrequis:

Utilisation du script afin d'installer le StorageClasse: Longhorn (celui-ci ne sera utilisé qu'une seule fois). Pour le lancer **ne pas utiliser sudo** (*à condition que l'utilisateur soit autoriser à utiliser kubectl.*)

```bash
bash ./Helm_Install.sh
```

---

---

## Méthode 1 (basique et pas à pas)

L'avantage de cette méthode et de pouvoir vérifier à chaque étape,

l'association/bonne exécution des différents fichiers.

Création du répertoire de travail:

```bash
mkdir -p tp-odoo
```

On va dans le dossier:

```bash
cd tp-odoo
```

Création des différents manifestes odoo

Vérification de la validité de chaque manifeste avec le plugins kubeval

#### POSTGRESQL

Création du namespace afin d'isoler l'application

```bash
kubectl apply -f odoo-namespace.yaml
```

Vérification de la création

```bash
kubectl -n tp-odoo get ns
```

Création de la demande de volume persistent (*"+/-équivalent à une partition"*) dans le longhorn (stockage persistent)

```bash
kubectl apply -f pvc-odoo-claim.yaml
```

Création du secret (chiffrement du mot de passe)

```bash
kubectl create secret generic postgresql-password --from-literal=odoo=YOUR_PASSWORD -n tp-odoo --dry-run=client -o yaml > odoo-pgsql-secret.yaml
kubectl apply -f odoo-pgsql-secret.yaml 
```

Déploiement de postgresql

```bash
kubectl apply -f postgresql-deployment.yaml
```

Défini le type de service et les ports utilisés par le container sur le worker

```bash
kubectl apply -f postgresql-service.yaml
```

Vérification (des objets dans le namespace tp-odoo)

```bash
kubectl -n tp-odoo get all                       
```

ou

```bash
kubectl -n tp-odoo get pod <nom> # Affiche les infos du conteneur
-----------------------rs  <nom>  # Affiche les infos sur le réplicas du conteneur
-----------------------pvc  <nom> # Affiche les infos du Persistent Volume Claim
-----------------------svc <nom> # Affiche les infos du service (de l'application, ports)
```

Avoir les informations complètes de chaque objets

```bash
kubectl -n tp-odoo describe pod <nom> # Affiche les infos du conteneur
--------------------------- rs <nom>  # Affiche les infos sur le réplicas du conteneur
--------------------------- pvc <nom> # Affiche les infos du Persistent Volume Claim
--------------------------- svc <nom> # Affiche les infos du service (de l'application, ports)
```

Pour se connecter au pod odoo-postgresql

```bash
kubectl exec -it <nom du pod> --  psql -h localhost -U odoo --password -p 5432 db-odoo-postgresql
```

#### odoo

La méthodologie applicative est identique à celle de postgresql

```bash
kubectl apply -f pvc-odoo-claim.yaml
kubectl apply -f odoo-deployment.yaml
kubectl apply -f odoo-service.yaml
```

---

---

## Méthode 2 (plus directe et rapide)

Inconvénient nécessite de prendre chaque éléments pour le débeug

Création du répertoire de travail

```bash
mkdir -p tp-odoo
```

On se déplace dans le répertoire de travail et on créer les manifestes

```bash
cd tp-odoo
```

Clone du repository existant sur le github

```bash
git clone https://github.com/geds3169/TP-odoo.git  #des manifestes préalablement créés.
```

Création du secret (chiffrement du mot de passe)

```bash
kubectl create secret generic postgresql-password --from-literal=odoo=YOUR_PASSWORD -n tp-odoo --dry-run=client -o yaml > odoo-pgsql-secret.yaml
kubectl apply -f odoo-pgsql-secret.yaml
```

Mise en oeuvre des différents fichier yaml contenu dans le répertoire du projet (création des conteneur, ect...)

```bash
kubectl apply -f .
```

---

---

Si une erreur se produit lors de l'execution de la cmd:

```bash
kubectl apply -f . # ne pas oublier le .
```

Relancer la cmd:

```bash
kubectl apply -f .
```

Cela devrait fonctionner à la deuxième reprise.

***Update:***

L'ajout de 01 au début du fichier 01-odoo-deployment.yaml semble règler le problème,

il semble y avoir une hiérarchie lors d'execution de l'"apply"

---

---

#### Supprimer tout ce qui est relatif au projet

```bash
kubectl delete ns tp-odoo
```

Vérification

```bash
kubectl get ns
```

---

---

#### Nota bene:

Pour une meilleure résilience l'ajout de ces clés valeurs pourraient être un plus

Dans postgresql-deployment.yaml

spec:
 replicas: 1
 replicas: 1
 strategy:
 type: Recreate
