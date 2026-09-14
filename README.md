# Script d'installation Laravel + Filament

Crée en une commande un projet Laravel + Filament + SQLite, servi par Herd, avec un compte admin, un premier commit Git prêt à être poussé sur GitLab.

---

## Dépendances nécessaires

Avant de lancer le script, assure-toi d'avoir installé :

- Laravel Herd
- PHP *(fourni par Herd)*
- Composer *(fourni par Herd)*
- Laravel Installer *(fourni par Herd)*
- Node.js *(inclut npm)*
- Git

👉 Liens de téléchargement, commandes d'installation et points d'attention : voir la section [Dépendances](#dépendances) tout en bas de ce README.

Le script vérifie lui-même leur présence au démarrage et s'arrête avec un message clair si l'une d'elles manque — mais installer tout en amont évite les allers-retours.

---

## Installation du script

⚠️ Remplace le chemin ci-dessous par le chemin complet **de ton propre script** dans les 3 commandes suivantes.

Exemple de chemin utilisé ici :

```text
/Users/tealforge/Dev/Scripts/new-laravel.sh
```

##

Lancer la commande dans un terminal quelconque 

```bash
chmod +x /Users/tealforge/Dev/Scripts/new-laravel.sh
```

```bash
nano ~/.zshrc
```

Ajouter dans le fichier :

```bash
alias laravel-tealforge="/Users/tealforge/Dev/Scripts/new-laravel.sh"
```

```bash
source ~/.zshrc
```

---

## Créer un projet

⚠️ la commande est a faire dans **ton repertoire de projet dev**

Exemple de chemin utilisé ici :

```text
/Users/tealforge/Dev
```

##

```bash
cd /Users/tealforge/Dev
laravel-tealforge
```

Le script demande :

```text
Nom de l'application :
Nom du panel Filament :
URL du back-office :
```

Si tu ne saisis pas d'URL de back-office, elle est générée automatiquement (nom du panel + `-adm`).

Le script affiche ensuite l'email et le mot de passe admin générés — attends la confirmation avant de continuer.

---

## Relier le projet à GitLab

Créer un projet **vide** sur GitLab (sans README, sans `.gitignore`, sans licence).

⚠️ Remplace `git@gitlab.com:organisation/mon-projet.git` par l'URL SSH ou HTTPS de **ton propre projet GitLab**.

```bash
cd /Users/tealforge/Dev/mon-projet

git remote add origin git@gitlab.com:organisation/mon-projet.git

git remote -v

git push -u origin main
```

Les envois suivants se font simplement avec :

```bash
git push
```

---

## Lancer le projet

```bash
cd /Users/tealforge/Dev/mon-projet
composer run dev
```

```text
CTRL + C
```
pour arrêter.

---

## Informations sur le projet généré

### Accès

| Service     | URL |
|-------------|-----|
| Application | `http://mon-projet.test` |
| Vite        | `http://mon-projet.test:5173` |
| Back-office | `http://mon-projet.test/tealforge-adm` |
| Login       | `http://mon-projet.test/tealforge-adm/login` |

### Compte administrateur

- Email : `admin@tealforge.com`
- Mot de passe : généré aléatoirement (18 caractères, affiché une seule fois par le script)

### Git

- Branche : `main`
- Premier commit : `Initialisation de la base laravel + Filament - Conçut par Tealforge`
- Aucun remote ajouté automatiquement
- `.env` et la base SQLite locale sont ignorés par Git

### composer run dev

Lance en parallèle Queue, Laravel Pail et Vite (Herd gère déjà le serveur HTTP, donc pas de `php artisan serve`).

### Autres commandes utiles

Modifier un remote existant :

```bash
git remote set-url origin git@gitlab.com:organisation/mon-projet.git
```

Supprimer un remote :

```bash
git remote remove origin
```

Vérifier la branche active :

```bash
git branch
```

---

> ℹ️ Pour recréer le compte administrateur après un clone sur un autre poste, voir le README du projet généré (section dédiée).

---

## Dépendances

Détail de chaque dépendance : à quoi elle sert, comment l'installer, comment vérifier qu'elle est bien reconnue, et les pièges fréquents.

### Laravel Herd

Sert l'application en local (`.test`) et fournit PHP, Composer et le Laravel Installer sans configuration manuelle.

- Téléchargement : [https://herd.laravel.com](https://herd.laravel.com)
- Installation : télécharger le `.dmg`, glisser Herd dans `/Applications`, puis **ouvrir l'application au moins une fois** et terminer l'assistant de configuration.
- Vérifier :
  ```bash
  herd --version
  ```

⚠️ **Piège fréquent** : installer Herd ne suffit pas à rendre la commande `herd` disponible immédiatement. Herd doit avoir été **lancé au moins une fois** (pour créer ses raccourcis dans le PATH), et le terminal doit être **fermé puis rouvert** (ou lancer `exec zsh`) après l'installation pour que le nouveau PATH soit pris en compte. Si `herd --version` répond `command not found` juste après l'installation, c'est presque toujours l'une de ces deux étapes qui manque.

### PHP

Fourni et géré automatiquement par Herd — aucune installation séparée n'est nécessaire dans la plupart des cas.

- Vérifier :
  ```bash
  php --version
  ```
- Si PHP n'est pas détecté alors que Herd est installé : ouvrir Herd → onglet **PHP**, installer une version, puis rouvrir le terminal.
- Sans Herd (solution de secours) :
  ```bash
  brew install php
  ```

### Composer

Fourni et géré automatiquement par Herd.

- Vérifier :
  ```bash
  composer --version
  ```
- Sans Herd (solution de secours) : [https://getcomposer.org/download/](https://getcomposer.org/download/)

### Laravel Installer

Fourni et géré automatiquement par Herd (le script vérifie et met à jour la version automatiquement à chaque exécution).

- Vérifier :
  ```bash
  laravel --version
  ```
- Sans Herd (solution de secours) :
  ```bash
  composer global require laravel/installer
  ```

### Node.js (inclut npm)

Nécessaire pour Vite (build des assets front).

- Téléchargement : [https://nodejs.org](https://nodejs.org) (choisir la version **LTS**)
- Installation alternative via Homebrew :
  ```bash
  brew install node
  ```
- Vérifier :
  ```bash
  node --version
  npm --version
  ```

npm est installé automatiquement avec Node.js — il n'y a rien à installer séparément pour lui.

### Git

Nécessaire pour l'initialisation du dépôt local et l'envoi vers GitLab.

- Installation via Homebrew :
  ```bash
  brew install git
  ```
- Téléchargement alternatif : [https://git-scm.com/downloads](https://git-scm.com/downloads)
- Vérifier :
  ```bash
  git --version
  ```
- Identité Git requise avant de lancer le script :
  ```bash
  git config --global user.name "Prénom Nom"
  git config --global user.email "email@tealforge.com"
  ```

### Après avoir tout installé

Une fois les dépendances installées, vérifie-les toutes d'un coup avant de lancer le script :

```bash
herd --version
php --version
composer --version
laravel --version
node --version
npm --version
git --version
```

Si l'une de ces commandes échoue avec `command not found` **alors que tu viens d'installer l'outil correspondant**, ferme et rouvre le terminal avant de relancer le script.