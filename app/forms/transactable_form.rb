# frozen_string_literal: true
class TransactableForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  AVAILABLE_ACTION_TYPES = [:time_based_booking, :event_booking,
                            :subscription_booking, :purchase_action, :no_action_booking, :offer_action].freeze
  model :transactable

  property :currency
  validates :currency, presence: true, allow_nil: false, currency: true
  property :enabled
  property :transactable_type
  property :action_type
  property :company, populate_if_empty: -> { model.creator&.default_company },
                     prepopulator: ->(_options) { self.company ||= model.creator&.default_company }
  property :location, populate_if_empty: -> { model.company.locations.first if model.transactable_type.skip_location? }
  property :photo_ids
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
      configuration = configuration
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
        AVAILABLE_ACTION_TYPES.select { |key| configuration.key?(key) }.each do |action|
          next if (action_configuration = configuration.delete(action)).nil?
          validation = action_configuration.delete(:validation)
          validates action, validation if validation.present?
          property action, form: "#{action.to_s.camelize}Form".constantize.decorate(action_configuration),
                           populator: ->(fragment:, **) {
                                        return skip! unless fragment[:enabled] == 'true'
                                        send("#{action}=", model.send("build_#{action}", transactable: model)) if send(action).blank?
                                        self.action_type = send(action).model if fragment[:enabled] == 'true'
                                      },
                           prepopulator: ->(_options) {
                                           return if send(action).present?
                                           send("#{action}=", "Transactable::#{action.to_s.camelize}".constantize.new(transactable: model, transactable_type_action_type: model.transactable_type.send(action))) if send(action).blank?
                                           model.action_type ||= send(action).model
                                         }
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
