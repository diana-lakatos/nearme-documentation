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

  def image=(value)
    super(value)
    if valid?
      model.image = value
      model.save!
      super(model.image)
    end
  end
end
