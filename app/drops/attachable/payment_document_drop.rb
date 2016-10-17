class Attachable::PaymentDocumentDrop < BaseDrop
  # @return [Attachable::PaymentDocument]
  attr_reader :payment_document

  # @!method file
  #   @return [PaymentDocumentUploader] file uploader object
  # @!method created_at
  #   @return [ActiveSupport::TimeWithZone]
  delegate :file, :created_at, to: :payment_document

  def initialize(payment_document)
    @payment_document = payment_document.decorate
  end

  # @return [String] file url
  def file_url
    @payment_document.file.url
  end

  # @return [String] file name
  def file_name
    @payment_document[:file]
  end
end
