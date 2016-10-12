# encoding: utf-8
class CkeditorAttachmentFileUploader < BaseCkeditorUploader
  include Ckeditor::Backend::CarrierWave

  def extension_white_list
    Ckeditor.attachment_file_types
  end
end
