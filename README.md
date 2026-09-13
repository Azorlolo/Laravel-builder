# Script d'installation Laravel + Filament

Crée en une commande un projet Laravel + Filament + SQLite, servi par Herd, avec un compte admin, un premier commit Git prêt à être poussé sur GitLab.

---

## Installation du script

⚠️ Remplace le chemin ci-dessous par le chemin complet **de ton propre script** dans les 3 commandes suivantes.

Exemple de chemin utilisé ici :

```text
/Users/tealforge/Dev/Scripts/new-laravel.sh
```

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