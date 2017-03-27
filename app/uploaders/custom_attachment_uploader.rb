# frozen_string_literal: true
# encoding: utf-8
class CustomAttachmentUploader < PrivateFileUploader
  def store_dir
    "#{instance_prefix}/uploads/attachments/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
