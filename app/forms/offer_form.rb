# frozen_string_literal: true
class OfferForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections

  def initialize(model)
    super(model)
  end

  class << self
    def decorate(configuration)
      Class.new(self) do
        if (customizations_configuration = configuration.delete(:customizations)).present?
          add_validation(:customizations, customizations_configuration)
          property :customizations, form: CustomizationsForm.decorate(customizations_configuration),
                                    from: :customizations_open_struct
        end
        inject_custom_attributes(configuration)
        inject_dynamic_fields(configuration, whitelisted: [ :state_event, :dates_fake, :interval, :start_on, :country_name, :mobile_number, :quantity, :book_it_out, :exclusive_price, :start_minute, :start_time, :starts_at, :end_minute, :guest_notes, :payment_method_id, :booking_type, :delivery_type, :delivery_ids, :inbound_pickup_date, :outbound_pickup_date, :outbound_return_address_address, :outbound_return_address_suburb, :outbound_return_address_postcode, :outbound_return_address_state, :outbound_return_address_country, :inbound_pickup_address_address, :inbound_pickup_address_suburb, :inbound_pickup_address_postcode, :inbound_pickup_address_state, :inbound_pickup_address_country, :inbound_sender_lastname, :outbound_receiver_lastname, :inbound_sender_firstname, :outbound_receiver_firstname, :inbound_sender_phone, :outbound_receiver_phone, :dates, :step_control, :total_amount_check, :transactable_pricing_id, :transactable_id, :use_billing])
      end
    end
  end

  property :_destroy, virtual: true

  # @!attribute reservation_type_id
  #   @return [Integer] numeric identifier for the associated reservation type
  #     defining custom attributes of offer
  property :reservation_type_id

  # @!attribute quantity
  #   @return [Integer] quantity of ordered items
  property :quantity, default: 1

  # @!attribute transactable_pricing_id
  #   @return [Integer] numeric identifier for the associated pricing object
  #     defining pricing rules
  property :transactable_pricing_id
  validates :transactable_pricing_id, presence: true

  # @!attribute transactable_id
  #   @return [Integer] numeric identifier for the associated purchased/reserved
  #     transactable object
  property :transactable_id
  validates :transactable_id, presence: true

  def validate!(*args)
    t = Transactable.find_by(id: @fields['transactable_id'])
    model.creator_id = t.creator_id
    model.company_id = t.company_id
    model.currency = t.currency
    super
  end
end
