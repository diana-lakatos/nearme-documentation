# frozen_string_literal: true
class CkeditorAssetDrop < BaseDrop
  include ActionView::Helpers::NumberHelper

  # @!method id
  #   @return [Integer] id of the asset
  # @!method user
  #   @return [UserDrop] user owning the asset
  # @!method created_at
  #   @return [DateTime] created at time
  delegate :id, :user, :created_at, to: :source

  # @return [String] title of the attachment or file name if title is not present
  def title
    @source.title.presence || @source.data_file_name
  end

  # @return [String] file size in a human readable format
  # @todo -- allow user to choose format (filter) or remove from drop at all
  def data_file_size
    number_to_human_size(@source.data_file_size)
  end

  # @return [String] URL to the attachment
  # @todo -- depracate url filter
  def attachment_url
    urlify(routes.custom_asset_path(@source))
  end

  # @return [String] path to destroy the attachment
  # @todo -- depracate url filter
  def destroy_path
    routes.seller_attachment_path(@source)
  end
end
