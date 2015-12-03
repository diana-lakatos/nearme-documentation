class SellerAttachmentDrop < BaseDrop

  def initialize(seller_attachment)
    @seller_attachment = seller_attachment.decorate
  end

  # Title of the attachment
  def title
    @seller_attachment.title.presence || @seller_attachment.data_file_name
  end

  # URL to the attachment
  def attachment_url
    routes.seller_attachment_url(@seller_attachment)
  end

end
