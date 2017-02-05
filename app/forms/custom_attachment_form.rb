# frozen_string_literal: true
class CustomAttachmentForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(options)
      Class.new(self) do
        validates :file, options[:validation] if options[:validation].present?
      end
    end
  end
  property :file
end
