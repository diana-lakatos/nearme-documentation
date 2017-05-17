# frozen_string_literal: true
class CustomAttachmentsForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |field, options|
          property :"#{field}", form: CustomAttachmentForm.decorate(options, human_attribute_name(field)),
                                populate_if_empty: ->(as:, **) { CustomAttachment.new(custom_attribute: CustomAttributes::CustomAttribute.find_by_name(as)) },
                                prepopulator: ->(*) { send(:"#{field}=", CustomAttachment.new(custom_attribute: CustomAttributes::CustomAttribute.find_by_name(field.to_s))) if send(:"#{field}").nil? }
          add_validation(field, options)
        end
      end
    end

    def human_attribute_name(attr)
      # we might want to cache this, but will need to invalidate when name changes
      # + we probably will need I18n support
      CustomAttributes::CustomAttribute.find_by_name(attr).label
    end
  end
end
