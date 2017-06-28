# frozen_string_literal: true
class SellerAttachmentUploader < PrivateFileUploader
  include Ckeditor::Backend::CarrierWave

  ALLOWED_FILE_TYPES = Ckeditor.attachment_file_types + Ckeditor.image_file_types

  def extension_white_list
    ALLOWED_FILE_TYPES
  end
end
