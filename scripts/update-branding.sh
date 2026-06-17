#!/bin/bash
# =============================================================
# Stratechna Sign — Actualizar branding a partir de instância live
#
# Uso: bash scripts/update-branding.sh [container]
# Default container: sign-stratechna-web
#
# Extrai os ficheiros patchados do container e coloca-os
# na pasta branding/ para commit no repositório.
# =============================================================

set -e

CONTAINER="${1:-sign-stratechna-web}"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Extrair branding de $CONTAINER ==="

# Assets públicos
docker cp "$CONTAINER:/app/public/logo.svg"                        "$REPO_DIR/branding/public/logo.svg"
docker cp "$CONTAINER:/app/public/favicon.svg"                     "$REPO_DIR/branding/public/favicon.svg"
docker cp "$CONTAINER:/app/public/favicon.ico"                     "$REPO_DIR/branding/public/favicon.ico"
docker cp "$CONTAINER:/app/public/favicon-16x16.png"               "$REPO_DIR/branding/public/favicon-16x16.png"
docker cp "$CONTAINER:/app/public/favicon-32x32.png"               "$REPO_DIR/branding/public/favicon-32x32.png"
docker cp "$CONTAINER:/app/public/favicon-96x96.png"               "$REPO_DIR/branding/public/favicon-96x96.png"
docker cp "$CONTAINER:/app/public/apple-icon-180x180.png"          "$REPO_DIR/branding/public/apple-icon-180x180.png"
docker cp "$CONTAINER:/app/public/apple-touch-icon.png"            "$REPO_DIR/branding/public/apple-touch-icon.png"
docker cp "$CONTAINER:/app/public/apple-touch-icon-precomposed.png" "$REPO_DIR/branding/public/apple-touch-icon-precomposed.png"
docker cp "$CONTAINER:/app/public/preview.png"                     "$REPO_DIR/branding/public/preview.png"

# Views ERB
docker cp "$CONTAINER:/app/app/views/shared/_logo.html.erb"               "$REPO_DIR/branding/views/shared/_logo.html.erb"
docker cp "$CONTAINER:/app/app/views/shared/_powered_by.html.erb"         "$REPO_DIR/branding/views/shared/_powered_by.html.erb"
docker cp "$CONTAINER:/app/app/views/pages/landing.html.erb"              "$REPO_DIR/branding/views/pages/landing.html.erb"
docker cp "$CONTAINER:/app/app/views/start_form/_docuseal_logo.html.erb"  "$REPO_DIR/branding/views/start_form/_docuseal_logo.html.erb"
docker cp "$CONTAINER:/app/app/views/submit_form/_docuseal_logo.html.erb" "$REPO_DIR/branding/views/submit_form/_docuseal_logo.html.erb"
docker cp "$CONTAINER:/app/app/views/layouts/_head_tags.html.erb"         "$REPO_DIR/branding/views/layouts/_head_tags.html.erb"

# JS patchado
docker cp "$CONTAINER:/app/public/packs/js/form-396c98213f11329535fa.js"    "$REPO_DIR/branding/packs/js/form-396c98213f11329535fa.js"
docker cp "$CONTAINER:/app/public/packs/js/form-396c98213f11329535fa.js.gz" "$REPO_DIR/branding/packs/js/form-396c98213f11329535fa.js.gz"
docker cp "$CONTAINER:/app/public/packs/js/form-396c98213f11329535fa.js.br" "$REPO_DIR/branding/packs/js/form-396c98213f11329535fa.js.br"

echo "=== Branding extraido para branding/ ==="
echo "Faz: git add branding/ && git commit -m 'chore: actualizar branding' && git push"
