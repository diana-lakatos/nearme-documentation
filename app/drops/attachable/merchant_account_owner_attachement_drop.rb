# frozen_string_literal: true
class Attachable::MerchantAccountOwnerAttachement < BaseDrop

  # @!method file
  #   @return [PaymentDocumentUploader] file uploader object
  # @!method created_at
  #   @return [DateTime] when the object was created
  delegate :file, :created_at, to: :source

  # @return [String] file url
  # @todo - remove in favor url filter

  def file_url
    @source.file.url
  end

  # @return [String] file name
  # @todo - depracate - DIY
  def file_name
    @source[:file]
  end
end
