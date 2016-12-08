# frozen_string_literal: true
Ckeditor.setup do |config|
  require 'ckeditor/orm/active_record'
  config.asset_path = '/assets/ckeditor/'
  config.assets_languages = %w(en)
  config.attachment_file_types = %w(doc docx xls odt ods pdf rar zip tar tar.gz swf mp4 webm ogv css txt text js xlsx woff ttf eot svg)
  config.image_file_types = %w(jpg jpeg png gif tiff svg)
end
