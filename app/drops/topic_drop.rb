class TopicDrop < BaseDrop
  attr_reader :topic

  # id
  #   id of topic as integer
  # name
  #   name of topic as string
  delegate :id, :name, :data_source_contents, :projects, to: :topic

  def initialize(topic)
    @topic = topic
  end

  def show_url
    urlify(routes.topic_path(@topic))
  end

  def cover_image
    @topic.cover_image.url(:medium)
  end

  def cover_image_big
    @topic.cover_image.url(:big)
  end
end
