#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# CONFIGURATION
# ============================================================

ADMIN_EMAIL="admin@tealforge.com"
PASSWORD_LENGTH=18
GIT_INITIAL_COMMIT="Initialisation de la base laravel + Filament - Conçut par Tealforge"

CURRENT_STEP="Initialisation"

# ============================================================
# COULEURS
# ============================================================

RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'

# ============================================================
# LOGS
# ============================================================

title() {
    echo
    echo -e "${BOLD}============================================================${RESET}"
    echo -e "${BOLD} $1${RESET}"
    echo -e "${BOLD}============================================================${RESET}"
    echo
}

step() {
    CURRENT_STEP="$1"

    echo
    echo -e "${BLUE}${BOLD}▶ $1${RESET}"
    echo
}

info() {
    echo -e "  ${BLUE}•${RESET} $1"
}

success() {
    echo -e "  ${GREEN}✓${RESET} $1"
}

warning() {
    echo -e "  ${YELLOW}!${RESET} $1"
}

error() {
    echo
    echo -e "${RED}${BOLD}✗ ERREUR${RESET}"
    echo -e "  ${RED}$1${RESET}"
    echo
    exit 1
}

separator() {
    echo -e "${DIM}  ----------------------------------------------------------${RESET}"
}

# ============================================================
# GESTION DES ERREURS
# ============================================================

on_error() {
    local exit_code=$?
    local line_number=$1

    echo
    echo -e "${RED}${BOLD}✗ INSTALLATION INTERROMPUE${RESET}"
    echo
    echo -e "  Étape : ${CURRENT_STEP}"
    echo -e "  Ligne : ${line_number}"
    echo -e "  Code  : ${exit_code}"
    echo
    echo -e "${YELLOW}  Consulte le message affiché juste au-dessus.${RESET}"
    echo

    exit "$exit_code"
}

trap 'on_error $LINENO' ERR

# ============================================================
# MOT DE PASSE
# ============================================================

random_char() {
    local chars="$1"
    local chars_length=${#chars}
    local random_number
    local index

    random_number=$(od -An -N2 -tu2 /dev/urandom | tr -d ' ')
    index=$((random_number % chars_length))

    printf '%s' "${chars:index:1}"
}

generate_password() {
    local uppercase='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local lowercase='abcdefghijklmnopqrstuvwxyz'
    local digits='0123456789'
    local specials='!@#$%&*_-+=?'
    local all_chars="${uppercase}${lowercase}${digits}${specials}"

    local password_chars=()
    local i
    local j
    local tmp
    local random_number

    # Au moins une majuscule
    password_chars+=("$(random_char "$uppercase")")

    # Au moins une minuscule
    password_chars+=("$(random_char "$lowercase")")

    # Au moins un chiffre
    password_chars+=("$(random_char "$digits")")

    # Au moins un caractère spécial
    password_chars+=("$(random_char "$specials")")

    # Complète jusqu'à 18 caractères
    for ((i=4; i<PASSWORD_LENGTH; i++)); do
        password_chars+=("$(random_char "$all_chars")")
    done

    # Mélange Fisher-Yates
    for ((i=PASSWORD_LENGTH-1; i>0; i--)); do
        random_number=$(od -An -N2 -tu2 /dev/urandom | tr -d ' ')
        j=$((random_number % (i + 1)))

        tmp="${password_chars[i]}"
        password_chars[i]="${password_chars[j]}"
        password_chars[j]="$tmp"
    done

    printf '%s' "${password_chars[@]}"
}

# ============================================================
# VÉRIFICATION D'UNE COMMANDE
# ============================================================

check_command() {
    local command_name="$1"
    local label="$2"
    local version

    info "Vérification de $label..."

    if ! command -v "$command_name" >/dev/null 2>&1; then
        error "$label n'est pas installé ou n'est pas disponible dans le PATH."
    fi

    version=$("$command_name" --version 2>/dev/null | head -n 1 || true)

    if [ -n "$version" ]; then
        success "$label : $version"
    else
        success "$label détecté"
    fi
}

# ============================================================
# DÉMARRAGE
# ============================================================

title "INSTALLATION LARAVEL + FILAMENT"

info "Script lancé"
info "Répertoire de création : $(pwd)"
info "Script : ${BASH_SOURCE[0]}"

echo

success "Initialisation terminée"

# ============================================================
# 1. DÉPENDANCES
# ============================================================

step "1/12 — Vérification des dépendances"

check_command herd "Laravel Herd"
check_command php "PHP"
check_command composer "Composer"
check_command laravel "Laravel Installer"
check_command node "Node.js"
check_command npm "npm"
check_command git "Git"

echo
success "Toutes les dépendances nécessaires sont disponibles"

# ============================================================
# 2. VERSION PHP
# ============================================================

step "2/12 — Vérification de PHP"

PHP_VERSION=$(php -r 'echo PHP_VERSION;')

info "PHP utilisé : $(command -v php)"
info "Version active : $PHP_VERSION"

if ! php -r 'exit(version_compare(PHP_VERSION, "8.2.0", ">=") ? 0 : 1);'; then
    error "PHP 8.2 minimum est requis."
fi

success "Version PHP compatible"

# ============================================================
# 3. LARAVEL INSTALLER
# ============================================================

step "3/12 — Vérification du Laravel Installer"

LARAVEL_PATH=$(command -v laravel)
LARAVEL_VERSION=$(laravel --version | head -n 1)

info "Laravel Installer : $LARAVEL_VERSION"
info "Emplacement : $LARAVEL_PATH"

# Herd fournit et gère son propre Laravel Installer.
if [[ "$LARAVEL_PATH" == *"Herd"* ]] || [[ "$LARAVEL_PATH" == *"herd"* ]]; then

    success "Laravel Installer géré par Herd"

    info "Vérification des mises à jour via Herd..."

    echo

    if ! herd laravel:update; then
        error "Impossible de vérifier ou mettre à jour le Laravel Installer via Herd."
    fi

    echo

    UPDATED_VERSION=$(laravel --version | head -n 1)

    success "Laravel Installer à jour : $UPDATED_VERSION"

else

    warning "Laravel Installer non fourni par Herd."
    info "Vérification via Composer global..."

    echo

    if ! composer global update laravel/installer --no-interaction; then
        error "Impossible de mettre à jour le Laravel Installer via Composer."
    fi

    echo

    UPDATED_VERSION=$(laravel --version | head -n 1)

    success "Laravel Installer à jour : $UPDATED_VERSION"

fi

# ============================================================
# 4. CONFIGURATION
# ============================================================

step "4/12 — Configuration du projet"

info "Le projet sera créé dans : $(pwd)"
echo

while true; do
    read -rp "  Nom de l'application : " APP_NAME

    if [ -z "$APP_NAME" ]; then
        warning "Le nom de l'application est obligatoire."
        continue
    fi

    APP_SLUG=$(echo "$APP_NAME" \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/ /-/g' \
        | sed 's/[^a-z0-9._-]//g')

    if [ -z "$APP_SLUG" ]; then
        warning "Le nom fourni n'est pas valide."
        continue
    fi

    if [ -e "$APP_SLUG" ]; then
        error "Le dossier '$APP_SLUG' existe déjà dans $(pwd)."
    fi

    break
done

echo

read -rp "  Nom du panel Filament [${APP_NAME}] : " PANEL_NAME

if [ -z "$PANEL_NAME" ]; then
    PANEL_NAME="$APP_NAME"
fi

# Slug du panel pour l'URL
PANEL_SLUG=$(echo "$PANEL_NAME" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/ /-/g' \
    | sed 's/[^a-z0-9._-]//g')

DEFAULT_PANEL_PATH="${PANEL_SLUG}-adm"

echo

read -rp "  URL du back-office [${DEFAULT_PANEL_PATH}] : " PANEL_PATH

if [ -z "$PANEL_PATH" ]; then
    PANEL_PATH="$DEFAULT_PANEL_PATH"
fi

# Nettoyage de l'URL saisie
PANEL_PATH=$(echo "$PANEL_PATH" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/ /-/g' \
    | sed 's/[^a-z0-9._-]//g')

if [ -z "$PANEL_PATH" ]; then
    error "L'URL du back-office n'est pas valide."
fi

HERD_DOMAIN="${APP_SLUG}.test"

echo
separator
echo

echo -e "  Application     : ${BOLD}$APP_NAME${RESET}"
echo -e "  Dossier         : ${BOLD}$APP_SLUG${RESET}"
echo -e "  Panel Filament  : ${BOLD}$PANEL_NAME${RESET}"
echo -e "  URL du panel    : ${BOLD}/$PANEL_PATH${RESET}"
echo -e "  Base de données : ${BOLD}SQLite${RESET}"
echo -e "  Frontend        : ${BOLD}Blade${RESET}"
echo -e "  URL Herd        : ${BOLD}http://$HERD_DOMAIN${RESET}"

echo
separator

# ============================================================
# 5. COMPTE ADMIN
# ============================================================

step "5/12 — Génération du compte administrateur"

info "Génération d'un mot de passe sécurisé de $PASSWORD_LENGTH caractères..."

ADMIN_PASSWORD="$(generate_password)"

success "Mot de passe généré"

echo
separator
echo

echo -e "  ${BOLD}COMPTE ADMINISTRATEUR${RESET}"
echo
echo -e "  Email       : ${GREEN}${ADMIN_EMAIL}${RESET}"
echo -e "  Mot de passe: ${GREEN}${ADMIN_PASSWORD}${RESET}"

echo
separator
echo

while true; do
    read -rp "  As-tu sauvegardé le mot de passe ? [oui/non] : " PASSWORD_SAVED

    case "$PASSWORD_SAVED" in

        oui|o|yes|y|OUI|YES|Oui|Yes)
            success "Mot de passe confirmé comme sauvegardé"
            break
            ;;

        non|n|no|N|NON|NO|Non|No)
            echo
            warning "Sauvegarde le mot de passe avant de continuer."
            echo
            echo -e "  Mot de passe : ${GREEN}${ADMIN_PASSWORD}${RESET}"
            echo
            ;;

        *)
            warning "Réponds par oui ou non."
            ;;

    esac
done

# ============================================================
# 6. CRÉATION LARAVEL
# ============================================================

step "6/12 — Création du projet Laravel"

info "Création de : $(pwd)/$APP_SLUG"
info "Base : SQLite"
info "Starter kit : aucun"
info "Frontend : Blade"
info "Laravel Boost : désactivé"

echo

laravel new "$APP_SLUG" \
    --database=sqlite \
    --no-interaction \
    --no-boost

echo

success "Projet Laravel créé"

info "Entrée dans le projet..."

cd "$APP_SLUG"

success "Répertoire courant : $(pwd)"

# ============================================================
# 7. FILAMENT
# ============================================================

step "7/12 — Installation de Filament"

info "Installation de filament/filament..."

echo

composer require filament/filament:"^5.0" \
    -W \
    --no-interaction

echo

success "Package Filament installé"

info "Installation du panel Filament..."

echo

php artisan filament:install \
    --panels \
    --no-interaction

echo

success "Panel Filament installé"

# ============================================================
# 8. CONFIGURATION FILAMENT + BDD + ADMIN
# ============================================================

step "8/12 — Configuration de Filament"

PANEL_PROVIDER="app/Providers/Filament/AdminPanelProvider.php"

info "Recherche du provider Filament..."

if [ ! -f "$PANEL_PROVIDER" ]; then
    error "Impossible de trouver $PANEL_PROVIDER."
fi

success "Provider Filament trouvé"

info "Configuration du nom du panel : $PANEL_NAME"
info "Configuration de l'URL du panel : /$PANEL_PATH"

export PANEL_PROVIDER
export PANEL_NAME
export PANEL_PATH

php <<'PHP'
<?php

$path = getenv('PANEL_PROVIDER');
$panelName = getenv('PANEL_NAME');
$panelPath = getenv('PANEL_PATH');

$content = file_get_contents($path);

if ($content === false) {
    fwrite(STDERR, "Impossible de lire le provider Filament.\n");
    exit(1);
}

$idNeedle = "->id('admin')";

if (!str_contains($content, $idNeedle)) {
    fwrite(
        STDERR,
        "Impossible de trouver ->id('admin') dans le provider Filament.\n"
    );
    exit(1);
}

$escapedPanelName = str_replace(
    ["\\", "'"],
    ["\\\\", "\\'"],
    $panelName
);

$idReplacement =
    "->id('admin')\n" .
    "            ->brandName('{$escapedPanelName}')";

$content = str_replace(
    $idNeedle,
    $idReplacement,
    $content
);

$pathNeedle = "->path('admin')";

if (!str_contains($content, $pathNeedle)) {
    fwrite(
        STDERR,
        "Impossible de trouver ->path('admin') dans le provider Filament.\n"
    );
    exit(1);
}

$escapedPanelPath = str_replace(
    ["\\", "'"],
    ["\\\\", "\\'"],
    $panelPath
);

$content = str_replace(
    $pathNeedle,
    "->path('{$escapedPanelPath}')",
    $content
);

if (file_put_contents($path, $content) === false) {
    fwrite(STDERR, "Impossible de modifier le provider Filament.\n");
    exit(1);
}
PHP

success "Nom du panel configuré : $PANEL_NAME"
success "URL du panel configurée : /$PANEL_PATH"

echo

info "Exécution des migrations Laravel..."

php artisan migrate --force

success "Base de données initialisée"

echo

info "Création de l'administrateur..."

export ADMIN_EMAIL
export ADMIN_PASSWORD

php artisan tinker --execute="
\$email = getenv('ADMIN_EMAIL');
\$password = getenv('ADMIN_PASSWORD');

\App\Models\User::updateOrCreate(
    ['email' => \$email],
    [
        'name' => 'Admin',
        'password' => \Illuminate\Support\Facades\Hash::make(\$password),
    ]
);
"

success "Administrateur créé"

# ============================================================
# 9. HERD + COMPOSER DEV
# ============================================================

step "9/12 — Configuration de Laravel Herd"

info "Configuration de APP_NAME et APP_URL..."

export APP_NAME
export HERD_DOMAIN

php <<'PHP'
<?php

$path = '.env';

$content = file_get_contents($path);

if ($content === false) {
    fwrite(STDERR, "Impossible de lire le fichier .env.\n");
    exit(1);
}

$appName = getenv('APP_NAME');
$appUrl = 'http://' . getenv('HERD_DOMAIN');

$escapedName = str_replace('"', '\\"', $appName);

$content = preg_replace(
    '/^APP_NAME=.*$/m',
    'APP_NAME="' . $escapedName . '"',
    $content
);

$content = preg_replace(
    '/^APP_URL=.*$/m',
    'APP_URL=' . $appUrl,
    $content
);

file_put_contents($path, $content);
PHP

success "APP_NAME : $APP_NAME"
success "APP_URL : http://$HERD_DOMAIN"

echo

info "Association du projet à Herd..."

herd link "$APP_SLUG"

success "Site Herd configuré"

echo

info "Configuration de Vite avec le domaine Herd..."

export HERD_DOMAIN

php <<'PHP'
<?php

$path = 'vite.config.js';

$content = file_get_contents($path);

if ($content === false) {
    fwrite(STDERR, "Impossible de lire vite.config.js.\n");
    exit(1);
}

$domain = getenv('HERD_DOMAIN');

$needle = 'export default defineConfig({';

if (!str_contains($content, $needle)) {
    fwrite(STDERR, "Impossible de trouver defineConfig dans vite.config.js.\n");
    exit(1);
}

if (!str_contains($content, "origin: 'http://{$domain}:5173'")) {
    $replacement = <<<JS
export default defineConfig({
    server: {
        host: '0.0.0.0',
        origin: 'http://{$domain}:5173',
        hmr: {
            host: '{$domain}',
        },
    },
JS;

    $content = str_replace(
        $needle,
        $replacement,
        $content
    );
}

if (file_put_contents($path, $content) === false) {
    fwrite(STDERR, "Impossible de modifier vite.config.js.\n");
    exit(1);
}
PHP

success "Vite configuré : http://$HERD_DOMAIN:5173"

echo

info "Adaptation de composer run dev..."
info "Suppression de php artisan serve uniquement"
info "Queue, Pail et Vite restent actifs"

php <<'PHP'
<?php

$path = 'composer.json';

$composer = json_decode(
    file_get_contents($path),
    true,
    512,
    JSON_THROW_ON_ERROR
);

$dev = $composer['scripts']['dev'] ?? null;

if (!is_array($dev)) {
    fwrite(STDERR, "Script Composer 'dev' introuvable.\n");
    exit(1);
}

foreach ($dev as &$command) {

    if (!str_contains($command, 'npx concurrently')) {
        continue;
    }

    $command = str_replace(
        '"php artisan serve --host=localhost" ',
        '',
        $command
    );

    $command = str_replace(
        '"php artisan serve" ',
        '',
        $command
    );

    $command = str_replace(
        '--names=server,queue,logs,vite',
        '--names=queue,logs,vite',
        $command
    );

    $command = str_replace(
        '-c "#93c5fd,#c4b5fd,#fb7185,#fdba74"',
        '-c "#c4b5fd,#fb7185,#fdba74"',
        $command
    );
}

unset($command);

$composer['scripts']['dev'] = $dev;

file_put_contents(
    $path,
    json_encode(
        $composer,
        JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES
    ) . PHP_EOL
);
PHP

success "composer run dev configuré pour Herd"
success "Queue conservée"
success "Pail conservé"
success "Vite conservé"
success "php artisan serve supprimé"

# ============================================================
# 10. VÉRIFICATION
# ============================================================

step "10/12 — Vérification finale"

info "Vérification de Laravel..."

php artisan about >/dev/null

success "Laravel opérationnel"

info "Vérification de Filament..."

if ! php artisan list | grep -q "filament"; then
    error "Les commandes Filament ne sont pas disponibles."
fi

success "Filament opérationnel"

info "Vérification du compte administrateur..."

ADMIN_EXISTS=$(php artisan tinker --execute="
echo \App\Models\User::where(
    'email',
    getenv('ADMIN_EMAIL')
)->exists()
    ? 'yes'
    : 'no';
" 2>/dev/null)

if [[ "$ADMIN_EXISTS" != *"yes"* ]]; then
    error "Le compte administrateur n'a pas été trouvé."
fi

success "Compte administrateur opérationnel"

# ============================================================
# 11. Changement du README.md du projet.
# ============================================================

step "11/12 — Remplacement du README du projet"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_README="$SCRIPT_DIR/templates/README.md"

if [ ! -f "$TEMPLATE_README" ]; then
    error "Template README introuvable : $TEMPLATE_README"
fi

cp "$TEMPLATE_README" README.md

info "Remplacement des variables dans le README..."

sed -i '' \
    -e "s#{{APP_NAME}}#${APP_NAME}#g" \
    -e "s#{{APP_SLUG}}#${APP_SLUG}#g" \
    -e "s#{{HERD_DOMAIN}}#${HERD_DOMAIN}#g" \
    -e "s#{{PANEL_NAME}}#${PANEL_NAME}#g" \
    -e "s#{{PANEL_PATH}}#${PANEL_PATH}#g" \
    README.md

success "README du projet remplacé par le template administrateur"
success "Variables du README injectées (APP_NAME, APP_SLUG, HERD_DOMAIN, PANEL_NAME, PANEL_PATH)"

# ============================================================
# 12. INITIALISATION GIT
# ============================================================

step "12/12 — Initialisation du dépôt Git"

info "Vérification de l'identité Git..."

GIT_USER_NAME=$(git config --get user.name || true)
GIT_USER_EMAIL=$(git config --get user.email || true)

if [ -z "$GIT_USER_NAME" ] || [ -z "$GIT_USER_EMAIL" ]; then
    error "L'identité Git n'est pas configurée.

Configure-la avec :

git config --global user.name \"Prénom Nom\"
git config --global user.email \"email@tealforge.com\"

Puis relance le script."
fi

success "Identité Git : $GIT_USER_NAME <$GIT_USER_EMAIL>"

echo

info "Préparation du dépôt Git local..."

# Le projet vient d'être créé par ce script.
# Si Laravel a initialisé un dépôt automatiquement, on repart d'un dépôt
# propre afin de garantir un unique commit initial Tealforge.
if [ -d ".git" ]; then
    warning "Un dépôt Git existe déjà dans le projet généré."
    info "Réinitialisation du dépôt pour créer un historique propre..."
    rm -rf .git
fi

git init -b main >/dev/null

success "Dépôt Git initialisé sur la branche main"

echo

info "Vérification des fichiers sensibles..."

# S'assure que .env ne puisse pas être ajouté au dépôt.
if ! git check-ignore -q .env 2>/dev/null; then
    warning ".env n'est pas ignoré : ajout à .gitignore"
    printf '\n.env\n' >> .gitignore
fi

success ".env ignoré"

# S'assure que la base SQLite locale ne puisse pas être ajoutée au dépôt.
if [ -f "database/database.sqlite" ] && ! git check-ignore -q database/database.sqlite 2>/dev/null; then
    warning "database/database.sqlite n'est pas ignoré : ajout à .gitignore"
    printf '\n/database/*.sqlite\n/database/*.sqlite-*\n' >> .gitignore
fi

if [ -f "database/database.sqlite" ]; then
    success "Base SQLite locale ignorée"
else
    success "Aucune base SQLite locale à exclure"
fi

echo

info "Ajout des fichiers au dépôt..."

git add .

# Double sécurité avant le commit.
if git ls-files --error-unmatch .env >/dev/null 2>&1; then
    error ".env est suivi par Git. Commit annulé pour éviter d'exposer des secrets."
fi

if git ls-files --error-unmatch database/database.sqlite >/dev/null 2>&1; then
    error "database/database.sqlite est suivie par Git. Commit annulé."
fi

success "Fichiers préparés pour le commit"

echo

info "Création du commit initial..."

git commit -m "$GIT_INITIAL_COMMIT" >/dev/null

success "Commit créé : $GIT_INITIAL_COMMIT"

echo

info "Vérification des remotes Git..."

if [ -n "$(git remote)" ]; then
    error "Un remote Git est déjà configuré alors que le dépôt doit rester local."
fi

success "Aucun remote configuré"
success "Projet prêt à être publié ultérieurement sur GitLab"

# ============================================================
# RÉSUMÉ
# ============================================================

title "INSTALLATION TERMINÉE"

echo -e "  Application      : ${BOLD}$APP_NAME${RESET}"
echo -e "  Dossier          : ${BOLD}$(pwd)${RESET}"
echo -e "  Base             : ${BOLD}SQLite${RESET}"
echo -e "  Frontend         : ${BOLD}Blade${RESET}"
echo -e "  Back-office      : ${BOLD}Filament${RESET}"
echo -e "  Panel            : ${BOLD}$PANEL_NAME${RESET}"
echo -e "  Git              : ${BOLD}main — dépôt local${RESET}"

echo

separator

echo

echo -e "  Application      : ${GREEN}http://$HERD_DOMAIN${RESET}"
echo -e "  Vite             : ${GREEN}http://$HERD_DOMAIN:5173${RESET}"
echo -e "  Back-office      : ${GREEN}http://$HERD_DOMAIN/$PANEL_PATH${RESET}"
echo -e "  Login            : ${GREEN}http://$HERD_DOMAIN/$PANEL_PATH/login${RESET}"

echo

separator

echo

echo -e "  Email admin      : ${GREEN}${ADMIN_EMAIL}${RESET}"
echo -e "  Mot de passe     : ${GREEN}${ADMIN_PASSWORD}${RESET}"

echo

separator

echo

echo -e "  Commit initial   : ${BOLD}$GIT_INITIAL_COMMIT${RESET}"
echo -e "  Remote Git       : ${BOLD}aucun${RESET}"

# ============================================================
# OUVERTURE
# ============================================================

step "Ouverture de l'application"

info "Ouverture du site via Herd..."

herd open

success "Application ouverte"

# ============================================================
# DEV
# ============================================================

step "Lancement de l'environnement de développement"

info "Herd gère le serveur HTTP"
info "Lancement de Queue / Pail / Vite"
info "Utilise CTRL+C pour arrêter"

echo
separator
echo

composer run dev