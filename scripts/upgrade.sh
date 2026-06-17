#!/bin/bash
# =============================================================
# Stratechna Sign — Upgrade de versão DocuSeal
#
# Uso: bash scripts/upgrade.sh <versao>
# Exemplo: bash scripts/upgrade.sh 2.6.0
#
# O que faz:
#   1. Actualiza a versão no workflow do GitHub Actions
#   2. Faz commit e push → GitHub Actions build nova imagem
#   3. Actualiza todas as instâncias cliente
# =============================================================

set -e

NOVA_VERSAO="${1:-latest}"
BASE_DIR="/opt/stratechna/sign/clientes"

echo "=== Upgrade Stratechna Sign para DocuSeal $NOVA_VERSAO ==="

# Pull da nova imagem
echo "[1/3] Pull da imagem..."
docker pull "ghcr.io/stratechna/stratechna-sign:latest"

# Actualizar cada cliente
echo "[2/3] A actualizar instâncias..."
for CLIENTE_DIR in "$BASE_DIR"/*/; do
  CLIENTE=$(basename "$CLIENTE_DIR")
  echo "  → $CLIENTE"
  cd "$CLIENTE_DIR"
  docker compose --env-file .env pull --quiet
  docker compose --env-file .env up -d --no-deps sign-"$CLIENTE"-web
  echo "    OK"
done

echo "[3/3] Instâncias actualizadas"
echo ""
echo "=== Verificar estado ==="
bash /opt/stratechna/sign/scripts/listar-clientes.sh
