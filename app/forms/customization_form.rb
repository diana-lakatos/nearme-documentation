# frozen_string_literal: true
class CustomizationForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  property :id
  property :custom_model_type_id
  property :_destroy, virtual: true

  def _destroy=(value)
    model.mark_for_destruction if value == '1'
  end

  def _destroy
    '1' if model.marked_for_destruction?
  end

  class << self
    def decorate(configuration)
      Class.new(self) do
        if (custom_images_configuration = configuration.delete(:custom_images)).present?
          validation = custom_images_configuration.delete(:validation)
          validates :custom_images, validation if validation.present?
          property :custom_images, form: CustomImagesForm.decorate(custom_images_configuration),
                                   from: :custom_images_open_struct,
                                   populate_if_empty: :custom_images_open_struct!,
                                   prepopulator: ->(_options) { self.custom_images ||= model.default_images_open_struct }

        end
        if (custom_attachments_configuration = configuration.delete(:custom_attachments)).present?
          validation = custom_attachments_configuration.delete(:validation)
          validates :custom_attachments, validation if validation.present?
          property :custom_attachments, form: CustomAttachmentsForm.decorate(custom_attachments_configuration),
                                        from: :custom_attachments_open_struct,
                                        populate_if_empty: :custom_attachments_open_struct!,
                                        prepopulator: ->(_options) { self.custom_attachments ||= model.default_custom_attachments_open_struct }

        end
        if (properties_configuration = configuration.delete(:properties)).present?
          validation = properties_configuration.delete(:validation)
          validates :properties, validation if validation.present?
          property :properties, form: PropertiesForm.decorate(properties_configuration)
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
