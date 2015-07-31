class SitemapUploader < BaseUploader
  def extension_white_list
    %w(xml)
  end

  def store_dir
    "#{instance_prefix}/uploads/sitemaps/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
