# Stratechna Sign

DocuSeal com a marca Stratechna.

    ghcr.io/stratechna/stratechna-sign:3.2      ← o que os clientes usam
    ghcr.io/stratechna/stratechna-sign:3.2.1    ← versão exacta
    ghcr.io/stratechna/stratechna-sign:latest   ← compatibilidade

## Licença e atribuição

O DocuSeal é AGPL-3.0 com termos adicionais (secção 7(b), `LICENSE_ADDITIONAL_TERMS`):
a atribuição original ao DocuSeal tem de ficar nas interfaces interactivas. Por isso o
«Powered by DocuSeal», com o link original, continua nas páginas — e a verificação
**falha se ele desaparecer**. Em tudo o resto, o produto chama-se Stratechna Sign.

## Como a marca é aplicada — e porque sobrevive às actualizações

1. **Versão fixa.** `ARG DOCUSEAL_VERSION` no `Dockerfile`.
2. **Só ficheiros próprios.** Imagens em `branding/public/`; textos próprios em
   `branding/ficheiros/stratechna.yml`, carregado depois das traduções do DocuSeal;
   o parcial do logótipo (`_logo.html.erb`, só o SVG), protegido por uma verificação da forma.
3. **Trocas por padrão, com mínimo.** `branding/aplicar.rb` muda o nome do produto na
   constante `PRODUCT_NAME` (um só ponto, usado em ~20 sítios), os títulos, o remetente dos
   emails e o nome nas traduções de todas as línguas. Se um padrão deixar de existir, **o
   build falha**.
4. **Teste antes de publicar.** `branding/verificar.sh` arranca a imagem e verifica as
   páginas, o manifest, o favicon e — por dentro, com `rails runner` — o nome do produto,
   a atribuição, os textos próprios e que nenhuma tradução ficou com o nome do upstream.
5. **Os clientes seguem a tag `3.2`**, que só avança com imagens que passaram o teste.

O JavaScript compilado não é tocado: os links que lá estão são da atribuição e das
páginas legais do DocuSeal.

## Actualizar o DocuSeal

O workflow `upstream.yml` abre um issue quando sai versão nova. Mudar
`DOCUSEAL_VERSION` e fazer push. Testar localmente:

    docker build -t sign:teste .
    bash branding/verificar.sh sign:teste
