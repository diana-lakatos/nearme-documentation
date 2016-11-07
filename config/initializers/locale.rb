require Rails.root.join('lib/i18n/backend/dnm_key_value')
if ActiveRecord::Base.connection.table_exists? Translation.table_name
  I18N_DNM_BACKEND = I18n::Backend::DNMKeyValue.new(Rails.cache)
  I18N_DNM_BACKEND.rebuild! if Rails.env.staging? || Rails.env.production?
  I18n.backend = I18n::Backend::Chain.new(I18N_DNM_BACKEND, I18n::Backend::Simple.new)
else
  message = "translations table does not exist, we can't use I18N_DNM_BACKEND"
  Rails.logger.warn(message)
  I18n.backend = I18n::Backend::Simple.new
end
