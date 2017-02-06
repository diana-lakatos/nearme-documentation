# frozen_string_literal: true
class CustomAttachmentForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(options, attr_name)
      Class.new(self) do
        validates :file, options[:validation] if options[:validation].present?

        define_singleton_method(:human_attribute_name) do |_attr|
          attr_name
        end
      end
    end
  end
  property :id, virtual: true
  property :file, virtual: true

  def id
    super.presence || model.id
  end

  def file
    super.presence || model.file
  end

  def file=(value)
    super(value)
    if valid?
      model.file = value
      model.save!
      super(model.file)
    end
  end
end
