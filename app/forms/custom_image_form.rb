# frozen_string_literal: true
class CustomImageForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(options, attr_name)
      Class.new(self) do
        add_validation(:image, options)
        define_singleton_method(:human_attribute_name) do |_attr|
          attr_name
        end
      end
    end
  end
  property :id, virtual: true
  property :image, virtual: true
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
