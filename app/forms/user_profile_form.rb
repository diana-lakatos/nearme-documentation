# frozen_string_literal: true
class UserProfileForm < BaseForm
  property :id
  class << self
    def decorate(configuration)
      Class.new(self) do
        if (properties_configuration = configuration.delete(:properties)).present?
          validation = properties_configuration.delete(:validation)
          validates :properties, validation if validation.present?
          property :properties, form: PropertiesForm.decorate(properties_configuration)
        end
        if (custom_images_configuration = configuration.delete(:custom_images)).present?
          validation = custom_images_configuration.delete(:validation)
          validates :custom_images, validation if validation.present?
          property :custom_images, form: CustomImagesForm.decorate(custom_images_configuration),
                                   from: :custom_images_open_struct,
                                   populate_if_empty: :custom_images_open_struct!,
                                   prepopulator: -> (options) { self.custom_images ||= model.default_images_open_struct }
        end
        if (custom_attachments_configuration = configuration.delete(:custom_attachments)).present?
          validation = custom_attachments_configuration.delete(:validation)
          validates :custom_attachments, validation if validation.present?
          property :custom_attachments, form: CustomAttachmentsForm.decorate(custom_attachments_configuration),
                                        from: :custom_attachments_open_struct,
                                        populate_if_empty: :custom_attachments_open_struct!,
                                        prepopulator: -> (options) { self.custom_attachments ||= model.default_custom_attachments_open_struct }
        end
        if (categories_configuration = configuration.delete(:categories)).present?
          validation = categories_configuration.delete(:validation)
          validates :categories, validation if validation.present?
          property :categories, form: CategoriesForm.decorate(categories_configuration),
                                from: :categories_open_struct
        end
        if (customizations_configuration = configuration.delete(:customizations)).present?
          validation = customizations_configuration.delete(:validation)
          validates :customizations, validation if validation.present?
          property :customizations, form: CustomizationsForm.decorate(customizations_configuration),
                                    from: :customizations_open_struct
        end
        if (availability_template_configuration = configuration.delete(:availability_template))
          validation = availability_template_configuration.delete(:validation)
          validates :availability_template, validation if validation.present?
          property :availability_template, form: AvailabilityTemplateForm.decorate(availability_template_configuration),
                                           populate_if_empty: AvailabilityTemplate,
                                           prepopulator: ->(*) { self.availability_template ||= AvailabilityTemplate.new }
        end
        configuration.each do |field, options|
          property :"#{field}"
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end
  end

  def custom_images_open_struct!(fragment:, **_args)
    hash = {}
    custom_images ||= model.custom_images + CustomImage.where(id: fragment.values.map { |h| h[:id] }, uploader_id: nil)
    model.custom_attribute_target.custom_attributes.where(attribute_type: 'photo').pluck(:id).each do |id|
      hash[id.to_s] = custom_images.detect { |ci| ci.custom_attribute_id == id }
    end
    OpenStruct.new(hash)
  end

  def custom_attachments_open_struct!(fragment:, **_args)
    hash = {}
    custom_attachments ||= model.custom_attachments + CustomAttachment.where(id: fragment.values.map { |h| h[:id] }, uploader_id: nil)
    model.custom_attribute_target.custom_attributes.where(attribute_type: 'file').pluck(:id).each do |id|
      hash[id.to_s] = custom_attachments.detect { |ci| ci.custom_attribute_id == id }
    end
    OpenStruct.new(hash)
  end
end
