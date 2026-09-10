#!/bin/bash
# Teste depois do build: arranca a imagem como um cliente a veria e falha se o
# nome do upstream estiver visível fora da atribuição exigida pela licença, ou
# se essa atribuição tiver desaparecido.
# Uso: branding/verificar.sh <imagem>     (corre no workflow antes de publicar)
set -uo pipefail
IMG=${1:?uso: verificar.sh <imagem>}
DIR=$(cd "$(dirname "$0")" && pwd)
ID=verif-sign-$$
PORTA=${PORTA:-18100}
B=http://127.0.0.1:$PORTA
FALHAS=0
falha() { FALHAS=$((FALHAS + 1)); echo "  FALHA: $1"; }
ok() { echo "  ok: $1"; }
trap 'docker rm -f $ID >/dev/null 2>&1' EXIT

docker run -d --name $ID -p 127.0.0.1:$PORTA:3000 \
  -e SECRET_KEY_BASE="verif$(head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')" "$IMG" >/dev/null

echo "== à espera do arranque =="
for i in $(seq 1 90); do
  curl -fs -o /dev/null "$B/up" && break
  if [ "$i" = 90 ]; then docker logs --tail 30 $ID; echo "FALHA: não arrancou"; exit 1; fi
  sleep 3
done
ok "arrancou"

# Numa página, DocuSeal só pode aparecer como atribuição: <a ...docuseal.com...>DocuSeal</a>
visivel() { # $1 descrição, $2 html
  local sem_attr c t
  sem_attr=$(printf '%s' "$2" | sed -E 's#<script[^>]*>.*</script>##g; s#<a [^>]*docuseal\.com[^>]*>DocuSeal</a>##g')
  c=$(printf '%s' "$sem_attr" | grep -oE '.{0,40}DocuSeal.{0,20}' | head -3)
  [ -z "$c" ] && ok "$1 sem DocuSeal fora da atribuição" || falha "$1 mostra DocuSeal: $c"
  t=$(printf '%s' "$2" | tr '\n' ' ' | sed -nE 's/.*<title>[[:space:]]*([^<]*[^[:space:]<])[[:space:]]*<\/title>.*/\1/p')
  [[ "$t" == *"Stratechna Sign"* ]] && ok "$1 título «$t»" || falha "$1 título «$t»"
}

echo "== páginas públicas =="
for L in pt-PT en-US; do
  visivel "/setup [$L]" "$(curl -fsS -H "Accept-Language: $L" "$B/setup")"
done
M=$(curl -fsS "$B/manifest.json")
echo "$M" | grep -q '"name": *"Stratechna Sign"' && ok "manifest.json com o nosso nome" || falha "manifest.json: $(echo "$M" | head -c 120)"
[ "$(curl -fs "$B/favicon.ico" | sha256sum | cut -c1-16)" = "$(sha256sum < "$DIR/public/favicon.ico" | cut -c1-16)" ] \
  && ok "favicon.ico é o nosso" || falha "favicon.ico não é o nosso"

echo "== por dentro da aplicação =="
docker cp "$DIR/verificar.rb" $ID:/tmp/verificar.rb
R=$(docker exec $ID sh -c 'cd /app && bin/rails runner /tmp/verificar.rb' 2>&1)
echo "$R" | grep -E '^(ok|FALHA|    )' | sed 's/^/  /'
echo "$R" | grep -q '^FALHA' && FALHAS=$((FALHAS + $(echo "$R" | grep -c '^FALHA')))
echo "$R" | grep -qE '^(ok|FALHA)' || { falha "rails runner não correu"; echo "$R" | tail -5; }

echo
if [ $FALHAS -gt 0 ]; then
  echo "VERIFICAÇÃO FALHOU ($FALHAS) — a imagem não deve ser publicada"
  exit 1
fi
echo "VERIFICAÇÃO OK — marca Stratechna Sign, atribuição ao DocuSeal mantida"
