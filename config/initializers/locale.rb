require 'i18n/backend/active_record'

I18n.backend = I18n::Backend::Chain.new(InstanceI18nBackend.new, I18n::Backend::Simple.new)
