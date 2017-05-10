# frozen_string_literal: true
class UserProfileForm < BaseForm
  property :id
  class << self
    def decorate(configuration)
      Class.new(self) do
        inject_custom_attributes(configuration)
        if (custom_images_configuration = configuration.delete(:custom_images)).present?
          add_validation(:custom_images, custom_images_configuration)
          property :custom_images, form: CustomImagesForm.decorate(custom_images_configuration),
                                   from: :custom_images_open_struct,
                                   populate_if_empty: :custom_images_open_struct!,
                                   prepopulator: ->(_options) { self.custom_images ||= model.default_images_open_struct }
        end
        if (custom_attachments_configuration = configuration.delete(:custom_attachments)).present?
          add_validation(:custom_attachments, custom_attachments_configuration)
          property :custom_attachments, form: CustomAttachmentsForm.decorate(custom_attachments_configuration),
                                        from: :custom_attachments_open_struct,
                                        populate_if_empty: :custom_attachments_open_struct!,
                                        prepopulator: ->(_options) { self.custom_attachments ||= model.default_custom_attachments_open_struct }
        end
        if (categories_configuration = configuration.delete(:categories)).present?
          add_validation(:categories, categories_configuration)
          property :categories, form: CategoriesForm.decorate(categories_configuration),
                                from: :categories_open_struct
        end
        if (customizations_configuration = configuration.delete(:customizations)).present?
          add_validation(:customizations, customizations_configuration)
          property :customizations, form: CustomizationsForm.decorate(customizations_configuration),
                                    from: :customizations_open_struct
        end
        if (availability_template_configuration = configuration.delete(:availability_template))
          add_validation(:availability_template, availability_template_configuration)
          property :availability_template, form: AvailabilityTemplateForm.decorate(availability_template_configuration),
                                           populate_if_empty: AvailabilityTemplate,
                                           prepopulator: ->(*) { self.availability_template ||= AvailabilityTemplate.new }
        end
        inject_dynamic_fields(configuration)
      end
    end
  end

  def custom_images_open_struct!(fragment:, **_args)
    hash = {}
    custom_images ||= model.custom_images + CustomImage.where(id: fragment.values.map { |h| h[:id] }, uploader_id: nil)
    model.custom_attribute_target.custom_attributes.where(attribute_type: 'photo').pluck(:id, :name).each do |id, name|
      hash[name] = custom_images.detect { |ci| ci.custom_attribute_id == id }
    end
    OpenStruct.new(hash)
  end

  def custom_attachments_open_struct!(fragment:, **_args)
    hash = {}
    custom_attachments ||= model.custom_attachments + CustomAttachment.where(id: fragment.values.map { |h| h[:id] }, uploader_id: nil)
    model.custom_attribute_target.custom_attributes.where(attribute_type: 'file').pluck(:id, :name).each do |id, name|
      hash[name] = custom_attachments.detect { |ci| ci.custom_attribute_id == id }
    end
    OpenStruct.new(hash)
  end
end
