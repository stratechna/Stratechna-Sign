# =============================================================
# Stratechna Sign — Imagem customizada baseada em DocuSeal
#
# Build: docker build -t ghcr.io/stratechna/stratechna-sign:latest .
# Push:  docker push ghcr.io/stratechna/stratechna-sign:latest
#
# O branding é aplicado sobre a imagem oficial DocuSeal:
#   - Assets públicos (logo, favicons)
#   - Views ERB (landing, logo, head_tags, powered_by)
#   - JS compilado patchado (form - Powered by)
# =============================================================

ARG DOCUSEAL_VERSION=latest
FROM docuseal/docuseal:${DOCUSEAL_VERSION}

LABEL org.opencontainers.image.source="https://github.com/stratechna/stratechna-sign"
LABEL org.opencontainers.image.description="Stratechna Sign — DocuSeal com branding Stratechna"
LABEL org.opencontainers.image.vendor="Stratechna"

# ── Assets públicos ───────────────────────────────────────────
COPY branding/public/logo.svg                        /app/public/logo.svg
COPY branding/public/favicon.svg                     /app/public/favicon.svg
COPY branding/public/favicon.ico                     /app/public/favicon.ico
COPY branding/public/favicon-16x16.png               /app/public/favicon-16x16.png
COPY branding/public/favicon-32x32.png               /app/public/favicon-32x32.png
COPY branding/public/favicon-96x96.png               /app/public/favicon-96x96.png
COPY branding/public/apple-icon-180x180.png           /app/public/apple-icon-180x180.png
COPY branding/public/apple-touch-icon.png             /app/public/apple-touch-icon.png
COPY branding/public/apple-touch-icon-precomposed.png /app/public/apple-touch-icon-precomposed.png
COPY branding/public/preview.png                     /app/public/preview.png

# ── Views ERB ─────────────────────────────────────────────────
COPY branding/views/shared/_logo.html.erb            /app/app/views/shared/_logo.html.erb
COPY branding/views/shared/_powered_by.html.erb      /app/app/views/shared/_powered_by.html.erb
COPY branding/views/pages/landing.html.erb           /app/app/views/pages/landing.html.erb
COPY branding/views/start_form/_docuseal_logo.html.erb  /app/app/views/start_form/_docuseal_logo.html.erb
COPY branding/views/submit_form/_docuseal_logo.html.erb /app/app/views/submit_form/_docuseal_logo.html.erb
COPY branding/views/layouts/_head_tags.html.erb      /app/app/views/layouts/_head_tags.html.erb

# ── JS patchado (Powered by DocuSeal → texto simples) ─────────
COPY branding/packs/js/form-396c98213f11329535fa.js     /app/public/packs/js/form-396c98213f11329535fa.js
COPY branding/packs/js/form-396c98213f11329535fa.js.gz  /app/public/packs/js/form-396c98213f11329535fa.js.gz
COPY branding/packs/js/form-396c98213f11329535fa.js.br  /app/public/packs/js/form-396c98213f11329535fa.js.br
COPY branding/views/shared/_title.html.erb       /app/app/views/shared/_title.html.erb

# cache-bust: 20260620145057
