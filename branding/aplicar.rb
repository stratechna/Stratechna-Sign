#!/usr/bin/env ruby
# frozen_string_literal: true

# Aplica a marca Stratechna ao DocuSeal, durante o build da imagem.
#
# Regras (ver README):
# - Nunca substitui por inteiro um ficheiro de código do upstream: troca texto por
#   padrão. Excepções: imagens em public/ e o parcial do logótipo (que é só o SVG),
#   este protegido por uma verificação da sua forma.
# - Cada troca declara quantas ocorrências espera no mínimo. Se o upstream mudar e
#   um padrão desaparecer, o build FALHA em vez de publicar uma imagem sem marca.
# - A atribuição "Powered by DocuSeal" fica nas interfaces: é exigida pelos termos
#   adicionais da licença (LICENSE_ADDITIONAL_TERMS, AGPL secção 7(b)).

require 'pathname'
require 'yaml'

APP = Pathname('/app')
PROPRIOS = Pathname('/tmp/branding')
MARCA = 'Stratechna Sign'
$erros = []

def trocar(rel, padrao, novo, minimo: 1)
  f = APP.join(rel)
  unless f.exist?
    $erros << "#{rel}: ficheiro não existe"
    return 0
  end
  texto = f.read
  n = texto.scan(padrao).size
  if n < minimo
    $erros << "#{rel}: «#{padrao.to_s[0, 70]}» aparece #{n}x, esperado >= #{minimo}"
    return 0
  end
  f.write(texto.gsub(padrao) { novo }) if n.positive?
  n
end

# ── 1. Nome do produto: um só ponto, usado em ~20 sítios ───────────────────
trocar('lib/docuseal.rb', "PRODUCT_NAME = 'DocuSeal'", "PRODUCT_NAME = '#{MARCA}'")

# ── 2. Atribuição exigida pela licença: continua a dizer DocuSeal ──────────
# O parcial usa Docuseal.product_name, que agora é o nosso; fixa-se o nome original.
trocar('app/views/shared/_powered_by.html.erb', '<%= Docuseal.product_name %></a>', 'DocuSeal</a>')

# ── 3. Títulos e metadados ──────────────────────────────────────────────────
%w[app/views/layouts/_head_tags.html.erb app/views/shared/_meta.html.erb].each do |f|
  trocar(f, "'DocuSeal | Open Source Document Signing'", "'#{MARCA} | Assinatura Electrónica'")
  trocar(f, "? 'DocuSeal' :", "? '#{MARCA}' :")
end
trocar('app/views/shared/_meta.html.erb', 'content="DocuSeal"', "content=\"#{MARCA}\"")
trocar('app/views/shared/_title.html.erb', '<span>DocuSeal</span>', "<span>#{MARCA}</span>")
trocar('app/views/start_form/_docuseal_logo.html.erb', '>DocuSeal</h1>', ">#{MARCA}</h1>")

# Títulos das páginas de assinatura: "<nome do documento> | DocuSeal"
titulos = APP.glob('app/views/**/*.erb').sum do |f|
  trocar(f.relative_path_from(APP).to_s, '| DocuSeal")', "| #{MARCA}\")", minimo: 0)
end
$erros << "títulos «| DocuSeal»: só #{titulos}, esperado >= 5" if titulos < 5

# ── 4. Remetente por omissão dos emails ────────────────────────────────────
trocar('app/mailers/application_mailer.rb', "default from: 'DocuSeal <info@docuseal.com>'",
       "default from: '#{MARCA} <suporte@stratechna.com>'")

# ── 5. Logótipo: o parcial é só o SVG. Substitui-se, mas só se a forma do ──
#       upstream (as variáveis que recebe) for a que conhecemos.
logo = APP.join('app/views/shared/_logo.html.erb')
forma = logo.read
esperado = ['local_assigns[:class]', 'local_assigns.fetch(:width', 'local_assigns.fetch(:height']
if esperado.all? { |e| forma.include?(e) } && forma.lines.size <= 10
  logo.write(PROPRIOS.join('_logo.html.erb').read)
else
  $erros << '_logo.html.erb do upstream mudou de forma — rever o nosso parcial do logótipo'
end

# ── 6. Traduções: o nome em todas as línguas; textos próprios no zz_stratechna.yml
i18n = 'config/locales/i18n.yml'
trocar(i18n, 'DocuSeal Pro', "#{MARCA} Premium", minimo: 10)
trocar(i18n, 'DocuSeal', MARCA, minimo: 50)
trocar(i18n, 'support@docuseal.com', 'suporte@stratechna.com', minimo: 0)
begin
  todas = YAML.safe_load(APP.join(i18n).read, aliases: true)
  sobra = todas.values.flat_map { |l| l.to_s.scan('DocuSeal') }.size
  $erros << "i18n.yml: #{sobra} DocuSeal por trocar" if sobra.positive?
  YAML.safe_load(APP.join('config/locales/zz_stratechna.yml').read, aliases: true)
rescue StandardError => e
  $erros << "traduções não carregam: #{e.message[0, 150]}"
end

if $erros.any?
  warn 'BRANDING FALHOU — o upstream mudou e estas trocas já não encaixam:'
  $erros.each { |e| warn "  - #{e}" }
  exit 1
end
puts "branding: nome do produto, atribuição mantida, #{titulos} títulos de páginas de assinatura, traduções"
