# frozen_string_literal: true
class CustomAttachmentsForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |field, options|
          property :"#{field}", form: CustomAttachmentForm.decorate(options, human_attribute_name(field)),
                                populate_if_empty: ->(as:, **) { CustomAttachment.new(custom_attribute: CustomAttributes::CustomAttribute.find(as)) },
                                prepopulator: ->(*) { send(:"#{field}=", CustomAttachment.new(custom_attribute: CustomAttributes::CustomAttribute.find(field.to_s))) if send(:"#{field}").nil? }

          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end

    def human_attribute_name(attr)
      # we might want to cache this, but will need to invalidate when name changes
      # + we probably will need I18n support
      CustomAttributes::CustomAttribute.find(attr.to_s).label
    end
  end
end
