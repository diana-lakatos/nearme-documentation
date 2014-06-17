class PrivateFileUploader < BaseUploader

  def extension_white_list
    %w(jpg jpeg png pdf)
  end

  def fog_public
    false
  end

  def store_dir
    "#{instance_prefix}/uploads/private/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end

