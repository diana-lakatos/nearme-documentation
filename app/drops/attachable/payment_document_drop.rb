# frozen_string_literal: true
class Attachable::PaymentDocumentDrop < BaseDrop
  # @return [Attachable::PaymentDocumentDrop]
  attr_reader :payment_document

  # @!method file
  #   @return [PaymentDocumentUploader] file uploader object
  # @!method created_at
  #   @return [DateTime] when the object was created
  delegate :file, :created_at, to: :payment_document

  def initialize(payment_document)
    @payment_document = payment_document.decorate
  end

  # @return [String] file url
  # @todo - remove in favor url filter
  def file_url
    @payment_document.file.url
  end

  # @return [String] file name
  # @todo - depracate - DIY
  def file_name
    @payment_document[:file]
  end
end
