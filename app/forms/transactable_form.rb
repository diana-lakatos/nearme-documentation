# frozen_string_literal: true
class TransactableForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  AVAILABLE_ACTION_TYPES = [:time_based_booking, :event_booking,
                            :subscription_booking, :purchase_action, :no_action_booking, :offer_action].freeze
  model :transactable

  def _destroy=(value)
    model.mark_for_destruction if checked?(value)
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
        if (photos_configuration = configuration.delete(:photos))
          add_validation(:photos, photos_configuration)
          collection :photos, form: PhotoForm,
                              populate_if_empty: Photo
        end
        if (customizations_configuration = configuration.delete(:customizations)).present?
          add_validation(:customizations, customizations_configuration)
          property :customizations, form: CustomizationsForm.decorate(customizations_configuration),
                                    from: :customizations_open_struct
        end
        if (location_configuration = configuration.delete(:location)).present?
          add_validation(:location, location_configuration)
          property :location, form: LocationForm.decorate(location_configuration),
                              populate_if_empty: Location,
                              prepopulator: ->(_options) { self.location ||= Location.new }
        end
        AVAILABLE_ACTION_TYPES.select { |key| configuration.key?(key) }.each do |action|
          next if (action_configuration = configuration.delete(action)).nil?
          add_validation(action, action_configuration)
          property action, form: "#{action.to_s.camelize}Form".constantize.decorate(action_configuration),
                           populator: ->(fragment:, **) {
                                        return skip! unless checked?(fragment[:enabled])
                                        send("#{action}=", model.send("build_#{action}", transactable: model, transactable_type_action_type: model.transactable_type.send(action))) if send(action).blank?
                                        self.action_type = send(action).model if checked?(fragment[:enabled])
                                      },
                           prepopulator: ->(_options) {
                                           return if send(action).present?
                                           send("#{action}=", "Transactable::#{action.to_s.camelize}".constantize.new(transactable: model, transactable_type_action_type: model.transactable_type.send(action))) if send(action).blank?
                                           model.action_type ||= send(action).model
                                         }
        end
        inject_dynamic_fields(configuration, whitelisted: [:name, :description, :capacity, :confirm_reservations, :location_id, :draft, :enabled, :deposit_amount, :quantity, :currency, :last_request_photos_sent_at, :activated_at, :rank, :transactable_type_id, :transactable_type, :insurance_value, :rental_shipping_type, :dimensions_template_id, :shipping_profile_id, :tag_list, :minimum_booking_minutes, :seek_collaborators, :photo_ids, :category_ids, :attachment_ids, :waiver_agreement_template_ids, :topic_ids, :group_ids])
      end
    end
  end

  # @!attribute currency
  #   @return [String] currency used for this Transactable's pricings
  property :currency
  
  # @!attribute enabled
  #   @return [Boolean] whether the Transactable is enabled; if not enabled, it will not be visible in search
  #     or purchasable
  property :enabled

  # @!attribute transactable_type
  #   @return [TransactableType] TransactableType to which this Transactable belongs
  property :transactable_type

  # @!attribute action_type
  #   @return [ActionTypeForm] {ActionTypeForm} to which this Transactable belongs
  property :action_type

  # @!attribute company
  #   @return [CompanyForm] {CompanyForm} to which this Transactable belongs
  property :company, populate_if_empty: -> { model.creator&.default_company },
                     prepopulator: ->(_options) { self.company ||= model.creator&.default_company }

  # @!attribute location
  #   @return [LocationForm] the {LocationForm} for this Transactable
  property :location, populate_if_empty: -> { model.company.locations.first if model.transactable_type.skip_location? }

  # @!attribute photo_ids
  #   @return [Array<Integer>] array of numeric identifiers for the photos associated with this Transactable
  property :photo_ids

  property :_destroy, virtual: true

  # @!attribute custom_images
  #   @return [CustomImagesForm] {CustomImagesForm} encapsulating the custom images for this Transactable
  # @!attribute custom_attachments
  #   @return [CustomAttachmentsForm] {CustomAttachmentsForm} encapsulating the custom attachments for this Transactable
  # @!attribute categories
  #   @return [CategoriesForm] {CategoriesForm} encapsulating the categories selected for this Transactable
  # @!attribute customizations
  #   @return [CustomizationsForm] {CustomizationsForm} encapsulating the customizations for this Transactable
  # @!attribute time_based_booking
  #   @return [TimeBasedBookingForm] {TimeBasedBookingForm} action for this Transactable (if available)
  # @!attribute event_booking
  #   @return [EventBookingForm] {EventBookingForm} action for this Transactable (if available)
  # @!attribute subscription_booking
  #   @return [SubscriptionBookingForm] {SubscriptionBookingForm} action for this Transactable (if available)
  # @!attribute purchase_action
  #   @return [PurchaseActionForm] {PurchaseActionForm} action for this Transactable (if available)
  # @!attribute no_action_booking
  #   @return [NoActionBookingForm] {NoActionBookingForm} action for this Transactable (if available)
  # @!attribute offer_action
  #   @return [OfferActionForm] {OfferActionForm} action for this Transactable (if available)

  # @!attribute photos
  #   @return [Array<PhotoForm>] array of {PhotoForm} forms encapsulating the photos for this Transactable

  validates :currency, presence: true, allow_nil: false, currency: true

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
