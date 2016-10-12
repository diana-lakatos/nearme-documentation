class ThemeStylesheetUploader < BaseUploader
  def extension_white_list
    %w(css)
  end

  def fog_attributes
    {
      'Cache-Control' => 'max-age=315576000, public',
      'Content-Encoding' => 'gzip',
      'Content-Type' => 'text/css'
    }
  end

  def store_dir
    "#{instance_prefix}/uploads/css/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
