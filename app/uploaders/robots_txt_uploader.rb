class RobotsTxtUploader < BaseUploader
  def extension_white_list
    %w(txt)
  end

  def store_dir
    "#{instance_prefix}/uploads/robots-txt/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
