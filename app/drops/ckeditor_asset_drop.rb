class CkeditorAssetDrop < BaseDrop
  include ActionView::Helpers::NumberHelper

  # @!method id
  #   @return [Integer] id of the asset
  # @!method user
  #   @return [UserDrop] user owning the asset
  # @!method created_at
  #   @return [ActiveSupport::TimeWithZone] created at time
  delegate :id, :user, :created_at, to: :source

  # @return [String] title of the attachment
  def title
    @source.title.presence || @source.data_file_name
  end

  # @return [String] file size in a human readable format
  def data_file_size
    number_to_human_size(@source.data_file_size)
  end

  # @return [String] URL to the attachment
  def attachment_url
    urlify(routes.custom_asset_path(@source))
  end

  # @return [String] path to destroy the attachment
  def destroy_path
    routes.seller_attachment_path(@source)
  end
end
