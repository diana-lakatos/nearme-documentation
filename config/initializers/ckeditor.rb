Ckeditor.setup do |config|
  require 'ckeditor/orm/active_record'
  config.asset_path = '/assets/ckeditor/'
  config.assets_languages = %w(en)
end
