# {{APP_NAME}}

Projet Laravel + Filament généré avec le script d'installation Tealforge.

---

## Stack technique

- **Framework** : Laravel
- **Frontend** : Blade
- **Base de données** : SQLite
- **Back-office** : Filament
- **Environnement local** : Laravel Herd
- **Build assets** : Vite

---

## 1. Prérequis

Avant de reprendre ce projet sur un poste, assure-toi d'avoir installé :

- [Laravel Herd](https://herd.laravel.com)
- PHP 8.2 minimum
- Composer
- Node.js et npm
- Git

---

## 2. Cloner le projet

```bash
# Remplacer l'URL ci-dessous par celle du remote GitLab une fois ajouté
git clone <URL_DU_REMOTE_GITLAB>
cd {{APP_SLUG}}
```

---

## 3. Installer les dépendances

```bash
composer install
npm install
```

---

## 4. Configurer l'environnement

Le fichier `.env` n'est pas versionné (il contient des informations sensibles). Il faut donc le recréer à partir de `.env.example` :

```bash
cp .env.example .env
php artisan key:generate
```

Vérifie que les valeurs suivantes correspondent bien à ton poste dans le `.env` généré :

```text
APP_NAME="{{APP_NAME}}"
APP_URL=http://{{HERD_DOMAIN}}
```

Puis exécute les migrations pour créer la base SQLite locale :

```bash
php artisan migrate
```

---

## 5. Recréer le compte administrateur

Le compte administrateur créé par le script d'installation d'origine **n'est pas versionné dans Git** (mot de passe généré aléatoirement, jamais stocké). Après un clone, il faut donc le recréer localement.

### Avec Tinker (mode interactif)

```bash
php artisan tinker
```

Puis exécuter :

```php
\App\Models\User::updateOrCreate(
    ['email' => 'admin@tealforge.com'],
    [
        'name' => 'Admin',
        'password' => \Illuminate\Support\Facades\Hash::make('TON_MOT_DE_PASSE'),
    ]
);
```

Puis quitter Tinker :

```text
exit
```

### En une seule commande

Pour éviter de passer par le mode interactif de Tinker :

```bash
php artisan tinker --execute="
\App\Models\User::updateOrCreate(
    ['email' => 'admin@tealforge.com'],
    [
        'name' => 'Admin',
        'password' => \Illuminate\Support\Facades\Hash::make('TON_MOT_DE_PASSE'),
    ]
);
"
```

### Recommandation sur le mot de passe

Utilise un mot de passe de 18 caractères minimum, contenant au moins :

- Une majuscule
- Une minuscule
- Un chiffre
- Un caractère spécial

### Connexion

```text
Email        : admin@tealforge.com
Mot de passe : TON_MOT_DE_PASSE
```

---

## 6. Lancer l'environnement de développement local

Associer le projet à Herd (si ce n'est pas déjà fait automatiquement) :

```bash
herd link
```

Lancer les processus de développement (queue, logs, Vite) :

```bash
composer run dev
```

> Herd gère déjà le serveur HTTP : `composer run dev` ne relance donc pas `php artisan serve`.

Pour arrêter les processus :

```text
CTRL + C
```

---

## 7. Accès au projet

| Service       | URL                                              |
|---------------|--------------------------------------------------|
| Application   | http://{{HERD_DOMAIN}}                            |
| Vite (dev)    | http://{{HERD_DOMAIN}}:5173                        |
| Back-office   | http://{{HERD_DOMAIN}}/{{PANEL_PATH}}              |
| Login admin   | http://{{HERD_DOMAIN}}/{{PANEL_PATH}}/login        |

---

## 8. Git

La branche principale du projet est :

```text
main
```

Pour récupérer les derniers changements :

```bash
git pull
```

Pour envoyer tes changements :

```bash
git push
```

### Fichiers non versionnés

Les fichiers suivants sont volontairement exclus du dépôt (`.gitignore`) car sensibles ou propres à chaque poste :

- `.env`
- La base SQLite locale (`database/*.sqlite`)

Chaque développeur doit donc reconfigurer son `.env` et recréer sa base locale après un clone (voir sections 4 et 5).

---

## 9. Notes complémentaires

- Ce projet a été initialisé sans starter kit Laravel.
- Le panel Filament est nommé **{{PANEL_NAME}}** et sert de back-office.
- Pour toute question sur la structure du projet ou les conventions utilisées, se référer à la documentation interne de l'équipe (à compléter si besoin).