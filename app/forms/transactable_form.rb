# frozen_string_literal: true
class TransactableForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  POPULATOR = lambda do |collection:, fragment:, index:, **_args|
    if (action_type = collection[index]).present?
      action_type
    else
      collection.insert(index, Transactable::ActionType.new(type: fragment[:type]))
    end
  end.freeze
  property :currency
  validates :currency, presence: true, allow_nil: false, currency: true
  property :location
  property :action_type
  property :_destroy, virtual: true

  def _destroy=(value)
    model.mark_for_destruction if value == '1'
  end

  def _destroy
    '1' if model.marked_for_destruction?
  end

  # FIXME: uncomment
  # validates :location, presence: true, unless: ->(record) { record.location_not_required }
  # validates :action_type, presence: true
  # validates :photos, length: { minimum: 1 }, unless: ->(record) { record.photo_not_required || !record.transactable_type.enable_photo_required }
  # validates :quantity, presence: true, numericality: { greater_than: 0 }, unless: ->(record) { record.action_type.is_a?(Transactable::PurchaseAction) }
  # validates :topics, length: { minimum: 1 }, if: ->(record) { record.topics_required && !record.draft.present? }
  # validates_associated :approval_requests, :action_type
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
        if (categories_configuration = configuration.delete(:categories)).present?
          validation = categories_configuration.delete(:validation)
          validates :categories, validation if validation.present?
          property :categories, form: CategoriesForm.decorate(categories_configuration),
                                from: :categories_open_struct
        end
        if (photos_configuration = configuration.delete(:photos))
          validation = photos_configuration.delete(:validation)
          validates :photos, validation if validation.present?
          collection :photos, form: PhotoForm,
                              populate_if_empty: Photo
        end
        if (customizations_configuration = configuration.delete(:customizations)).present?
          validation = customizations_configuration.delete(:validation)
          validates :customizations, validation if validation.present?
          property :customizations, form: CustomizationsForm.decorate(customizations_configuration),
                                    from: :customizations_open_struct
        end
        if (action_types_configuration = configuration.delete(:action_types)).present?
          validation = action_types_configuration.delete(:validation)
          validates :action_types, validation if validation.present?
          collection :action_types, form: ActionTypeForm.decorate(action_types_configuration),
                                    populator: POPULATOR,
                                    prepopulator: ->(_options) { self.action_types = model.transactable_type.action_types.enabled.map { |at| at.transactable_action_types.build } if self.action_types.size.zero? }
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
