class HeroImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  def store_dir
    "uploads/hero_images/#{model.id}/"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

end
