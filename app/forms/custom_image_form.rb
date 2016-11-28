# frozen_string_literal: true
class CustomImageForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(options)
      Class.new(self) do
        validates :image, options[:validation] if options[:validation].present?
      end
    end
  end
  property :image
end
