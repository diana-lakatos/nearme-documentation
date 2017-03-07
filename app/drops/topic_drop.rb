# frozen_string_literal: true
class TopicDrop < BaseDrop
  # @return [Topic]
  attr_reader :topic

  # @!method id
  #   @return [Integer] numeric identifier for this topic
  # @!method name
  #   @return [String] Name for this topic
  # @!method data_source_contents
  #   @return [Array<DataSourceContentDrop>] Data source contents for this topic
  delegate :id, :name, :data_source_contents, :is_followed, to: :topic

  def initialize(topic)
    @topic = topic
  end

  # @return [String] url for this topic
  # @todo -- depracate in favor of filter
  def show_url
    urlify(routes.topic_path(@topic))
  end

  # @return [String] cover image (url) for this topic - medium size
  # @todo -- depracate in favor of filter
  def cover_image
    @topic.cover_image.url(:medium)
  end

  # @return [String] cover image (url) for this topic - big size
  # @todo -- depracate in favor of filter
  def cover_image_big
    @topic.cover_image.url(:big)
  end

  # @return [String] generates a background-image style of the form 'background-image: url(...)'
  #   for the 'big' cover image if present, returns an empty string otherwise
  # @todo -- lets use some kind of ImageDrop/tag/filter with images and lets return pure url not css
  def background_style_big
    if cover_image_big.present?
      "background-image: url(#{ActionController::Base.helpers.image_url(cover_image_big)});"
    else
      ''
    end
  end

  # @return [String] returns url for image used on listing pages
  def listing_image_url
    @topic.image.url(:medium)
  end

  # @return [String] generates a background-image style of the form 'background-image: url(...)'
  #   for the 'medium' sized cover image if present, returns an empty string otherwise
  # @todo -- lets use some kind of ImageDrop/tag/filter with images and lets return pure url not css
  def background_style
    if cover_image.present?
      "background-image: url(#{ActionController::Base.helpers.image_url(cover_image)});"
    else
      ''
    end
  end
end
