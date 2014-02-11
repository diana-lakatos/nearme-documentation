I18N_DNM_BACKEND = I18n::Backend::DNMKeyValue.new(Rails.cache)
I18n.backend = I18n::Backend::Chain.new(I18N_DNM_BACKEND, I18n::Backend::Simple.new)
