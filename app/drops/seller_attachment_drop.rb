class SellerAttachmentDrop < BaseDrop
  include ActionView::Helpers::NumberHelper

  delegate :user, :created_at, to: :source

  # Title of the attachment
  def title
    @source.title.presence || @source.data_file_name
  end

  def data_file_size
    number_to_human_size(@source.data_file_size)
  end

  # URL to the attachment
  def attachment_url
    urlify(routes.seller_attachment_path(@source))
  end

  def destroy_path
    routes.seller_attachment_path(@source)
  end

end
