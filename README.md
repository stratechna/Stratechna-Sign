# Stratechna Sign

Imagem Docker customizada do [DocuSeal](https://www.docuseal.com) com branding Stratechna.

## Arquitectura

```
stratechna-sign/
├── Dockerfile                    # Imagem baseada em docuseal/docuseal:latest
├── branding/
│   ├── public/                   # Assets estáticos (logo, favicons)
│   ├── views/                    # Views ERB patchadas
│   │   ├── shared/               # _logo, _powered_by
│   │   ├── pages/                # landing
│   │   ├── start_form/           # _docuseal_logo
│   │   ├── submit_form/          # _docuseal_logo
│   │   └── layouts/              # _head_tags
│   └── packs/js/                 # JS compilado patchado
├── scripts/
│   ├── novo-cliente.sh           # Provisionar nova instância
│   ├── listar-clientes.sh        # Listar instâncias activas
│   ├── remover-cliente.sh        # Remover instância
│   ├── update-branding.sh        # Extrair branding do container live
│   └── upgrade.sh                # Upgrade de versão DocuSeal
└── .github/workflows/build.yml   # Build automático no GHCR
```

## Instâncias

Cada cliente tem a sua instância isolada em `/opt/stratechna/sign/clientes/<slug>/`:
- URL: `https://<slug>.sign.stratechna.com`
- Containers: `sign-<slug>-web`, `sign-<slug>-db`
- Rede interna isolada: `sign_<slug>_internal`
- BD separada, volume separado

## Criar nova instância

```bash
bash /opt/stratechna/sign/scripts/novo-cliente.sh <slug> <email-admin> [empresa]
# Exemplo:
bash /opt/stratechna/sign/scripts/novo-cliente.sh acme admin@acme.pt "ACME, Lda."
```

## Actualizar branding

Quando o branding muda (novo logo, textos, etc.):

```bash
# 1. Fazer as alterações manualmente no container sign-stratechna-web
# 2. Extrair para o repositório
bash scripts/update-branding.sh
# 3. Commit e push → GitHub Actions reconstrói a imagem
git add branding/
git commit -m "chore: actualizar branding"
git push
```

## Upgrade de versão DocuSeal

```bash
# Via GitHub Actions (recomendado):
# → Ir a Actions → Build Stratechna Sign → Run workflow → inserir versão

# Ou manualmente no servidor:
bash /opt/stratechna/sign/scripts/upgrade.sh 2.6.0
```

## Template docker-compose por cliente

O ficheiro `template/docker-compose.yml` usa a imagem customizada:
```yaml
image: ghcr.io/stratechna/stratechna-sign:latest
```

Quando o GitHub Actions constrói uma nova imagem, basta fazer pull em cada instância.
