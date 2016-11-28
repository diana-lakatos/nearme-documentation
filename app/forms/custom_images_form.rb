# frozen_string_literal: true
class CustomImagesForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |field, options|
          property :"#{field}", form: CustomImageForm.decorate(options),
                                populate_if_empty: -> (as:, **) { CustomImage.new(custom_attribute: CustomAttributes::CustomAttribute.find(as)) },
                                prepopulator: ->(*) { self.send(:"#{field}=", CustomImage.new(custom_attribute: CustomAttributes::CustomAttribute.find(field.to_s))) if send(:"#{field}").nil? }

          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end

    def human_attribute_name(attr)
      # we might want to cache this, but will need to invalidate when name changes
      CustomAttributes::CustomAttribute.find(attr).label
    end
  end
end
