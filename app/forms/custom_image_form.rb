# frozen_string_literal: true
class CustomImageForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(options, attr_name)
      Class.new(self) do
        if (image_configuration = options.delete(:image))
          add_validation(:image, image_configuration)
        end
        define_singleton_method(:human_attribute_name) do |_attr|
          attr_name
        end
      end
    end
  end

  # @!attribute id
  #   @return [Integer] numeric identifier for the custom image
  property :id, virtual: true

  # @!attribute image
  #   @return [File] image object associated with the custom image
  property :image, virtual: true

  # @!attribute url
  #   @return [String] url for the associated image
  property :url, virtual: true

  def id
    super.presence || model.id
  end

  def image
    super.presence || model.image
  end

  # @return [String] file name for the associated file
  def file_name
    File.basename(image.path.to_s).presence || image.filename
  end

  # @return [String] file extension for the associated file
  def file_extension
    File.extname(image.path.to_s.presence || image.filename)&.tr('.', '')
  end

  # @return [String] file url for the associated file
  def file_url
    image.url
  end

  # @return [String] uploader id for the associated file
  delegate :uploader_id, to: :image

  # @return [String] mime type (ie. image/png) for the associated file
  delegate :content_type, to: :image

  # @return [Time] date when the associated object was created
  def file_time
    model.created_at || Time.zone.now
  end

  # @return [Integer] size of the associated file in bytes
  def file_size
    image.size
  rescue
    nil
  end

  def image=(value)
    super(value)
    if valid?
      model.image = value
      model.save!
      super(model.image)
    end
  end
end
