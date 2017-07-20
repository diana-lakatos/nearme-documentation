# frozen_string_literal: true
class CustomizationForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections

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
        inject_custom_attributes(configuration)
        inject_dynamic_fields(configuration, whitelisted: [:customizable_id, :customizable_type, :user_id])
      end
    end
  end

  # @!attribute id
  #   @return [Integer] numeric identifier of the associated object
  property :id

  # @!attribute custom_model_type_id
  #   @return [Integer] numeric identifier of the associated
  #     CustomModelType
  property :custom_model_type_id

  property :_destroy, virtual: true

  # @!attribute customizable_id
  #   @return [Integer] numeric identifier for the object to which the
  #     customization is attached
  property :customizable_id

  # @!attribute customizable_type
  #   @return [String] type of the object to which the customization is
  #     attached; used in conjunction with customizable_id
  property :customizable_type

  # @!attribute custom_images
  #   @return [CustomImagesForm] associated custom images
  # @!attribute custom_attachments
  #   @return [CustomAttachmentsForm] associated custom attachments

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
