if ActiveRecord::Base.connection.table_exists? Translation.table_name
  I18N_DNM_BACKEND = I18n::Backend::DNMKeyValue.new(Rails.cache)
  I18n.backend = I18n::Backend::Chain.new(I18N_DNM_BACKEND, I18n::Backend::Simple.new)
else
  message = "translations table does not exist, we can't use I18N_DNM_BACKEND"
  Rails.env.test? ? raise(message) : Rails.logger.warn(message)
  I18n.backend = I18n::Backend::Simple.new
end
