# Stratechna Sign — DocuSeal com a marca Stratechna.
#
# A versão do DocuSeal está FIXA. Actualizar é mudar esta linha, de propósito:
# o aplicar.rb falha o build se alguma troca deixar de encaixar, e o verificar.sh
# (no workflow) falha se o nome do upstream ficar visível fora da atribuição
# exigida pela licença — ou se essa atribuição desaparecer.
ARG DOCUSEAL_VERSION=3.2.1
FROM docuseal/docuseal:${DOCUSEAL_VERSION}
ARG DOCUSEAL_VERSION

LABEL org.opencontainers.image.source="https://github.com/stratechna/Stratechna-Sign" \
      org.opencontainers.image.title="Stratechna Sign" \
      org.opencontainers.image.vendor="Stratechna" \
      org.opencontainers.image.version="${DOCUSEAL_VERSION}" \
      org.opencontainers.image.base.name="docuseal/docuseal:${DOCUSEAL_VERSION}"

# Imagens próprias (logótipo, favicons, pré-visualização)
COPY branding/public/ /app/public/

# Textos próprios: carregados depois do i18n.yml do DocuSeal
COPY branding/ficheiros/stratechna.yml /app/config/locales/zz_stratechna.yml

# Trocas por padrão, com mínimo de ocorrências; falha se não encaixarem
COPY branding/ficheiros/_logo.html.erb branding/aplicar.rb /tmp/branding/
RUN ruby /tmp/branding/aplicar.rb && rm -rf /tmp/branding
