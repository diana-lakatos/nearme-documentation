class Attachable::PaymentDocumentDrop < BaseDrop
  attr_reader :payment_document

  # name
  #   name of additional charge
  delegate :name, :file, :created_at, to: :payment_document

  def initialize(payment_document)
    @payment_document = payment_document.decorate
  end

  def file_url
    @payment_document.file.url
  end

  def file_name
    @payment_document[:file]
  end


end
