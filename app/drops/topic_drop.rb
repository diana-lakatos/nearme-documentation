class TopicDrop < BaseDrop

  # @return [Topic]
  attr_reader :topic

  # @!method id
  #   @return [Integer] numeric identifier for this topic
  # @!method name
  #   Name for this topic
  #   @return (see Topic#name)
  # @!method data_source_contents
  #   @return [Array<DataSourceContentDrop>] Data source contents for this topic
  # @todo Investigate/remove projects no longer present
  delegate :id, :name, :data_source_contents, :projects, to: :topic

  def initialize(topic)
    @topic = topic
  end

  # @return [String] url for this topic
  def show_url
    urlify(routes.topic_path(@topic))
  end

  # @return [String] cover image (url) for this topic - medium size
  def cover_image
    @topic.cover_image.url(:medium)
  end

  # @return [String] cover image (url) for this topic - big size
  def cover_image_big
    @topic.cover_image.url(:big)
  end

  # @return [String] generates a background-image style of the form 'background-image: url(...)'
  #   for the 'big' cover image if present, returns an empty string otherwise
  def background_style_big
    if cover_image_big.present?
      "background-image: url(#{ActionController::Base.helpers.image_url(cover_image_big)});"
    else
      ''
    end
  end

  # @return [String] generates a background-image style of the form 'background-image: url(...)'
  #   for the 'medium' sized cover image if present, returns an empty string otherwise
  def background_style
    if cover_image.present?
      "background-image: url(#{ActionController::Base.helpers.image_url(cover_image)});"
    else
      ''
    end
  end
end
