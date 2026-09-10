# frozen_string_literal: true

# Verificações por dentro da aplicação: bin/rails runner branding/verificar.rb
# Escreve uma linha "ok:" ou "FALHA:" por verificação.

def chk(desc, ok)
  puts "#{ok ? 'ok' : 'FALHA'}: #{desc}"
end

chk "product_name = #{Docuseal.product_name}", Docuseal.product_name == 'Stratechna Sign'

attr = ApplicationController.renderer.render(partial: 'shared/powered_by', locals: {})
chk 'atribuição «Powered by DocuSeal» mantida (licença, AGPL 7(b))',
    attr.include?('DocuSeal</a>') && attr.include?('docuseal.com')

%i[pt pt-PT].each do |l|
  chk "textos próprios carregados (docuseal_support #{l} = #{I18n.t('docuseal_support', locale: l)})",
      I18n.t('docuseal_support', locale: l) == 'Suporte Stratechna'
end
chk "textos próprios em inglês (en-GB = #{I18n.t('docuseal_support', locale: :'en-GB')})",
    I18n.t('docuseal_support', locale: :'en-GB') == 'Stratechna Support'
chk 'atribuição dos emails é a nossa (pt)',
    I18n.t('sent_using_product_name_open_source_software_html', locale: :pt,
                                                                product_url: 'x', product_name: 'y').include?('Stratechna Sign')

def textos(h) = h.is_a?(Hash) ? h.values.flat_map { |v| textos(v) } : [h].flatten.grep(String)

I18n.backend.send(:init_translations) unless I18n.backend.initialized?
sobras = I18n.available_locales.flat_map do |l|
  textos(I18n.backend.send(:translations)[l] || {}).grep(/DocuSeal/).map { |s| "#{l}: #{s[0, 60]}" }
end
chk "nenhuma tradução com DocuSeal (#{sobras.size})#{sobras.first(3).map { |s| "\n    #{s}" }.join}", sobras.empty?

chk "remetente por omissão = #{ApplicationMailer.default[:from]}", ApplicationMailer.default[:from].include?('Stratechna')
