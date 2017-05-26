# frozen_string_literal: true
class ReservationForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections

  def initialize(model)
    super(model)
  end

  validates :minimum_booking_minutes, presence: true

  validates :transactable_pricing_id, presence: true
  validates :transactable_id, presence: true

  class << self
    def decorate(configuration)
      Class.new(self) do
        if (periods_configuration = configuration.delete(:periods))
          collection :periods, form: ReservationPeriodForm.decorate(periods_configuration),
                               populator: ->(fragment:, **) {
                                            item = periods.find { |p| p.id.to_s == fragment['id'].to_s && fragment['id'].present? }
                                            if fragment['_destroy'] == '1'
                                              periods.delete(item)
                                              return skip!
                                            end
                                            item ? item : periods.append(model.periods.build)
                                          },
                               prepopulator: ->(_options) { periods << model.periods.build if periods.size.zero? }
          validates :periods, presence: true, length: { minimum: 1 }
        end

        inject_custom_attributes(configuration)
        inject_dynamic_fields(configuration, whitelisted: [:dates_fake, :interval, :start_on, :country_name, :mobile_number, :quantity, :book_it_out, :exclusive_price, :start_minute, :start_time, :starts_at, :end_minute, :guest_notes, :payment_method_id, :booking_type, :delivery_type, :delivery_ids, :inbound_pickup_date, :outbound_pickup_date, :outbound_return_address_address, :outbound_return_address_suburb, :outbound_return_address_postcode, :outbound_return_address_state, :outbound_return_address_country, :inbound_pickup_address_address, :inbound_pickup_address_suburb, :inbound_pickup_address_postcode, :inbound_pickup_address_state, :inbound_pickup_address_country, :inbound_sender_lastname, :outbound_receiver_lastname, :inbound_sender_firstname, :outbound_receiver_firstname, :inbound_sender_phone, :outbound_receiver_phone, :dates, :step_control, :total_amount_check, :transactable_pricing_id, :transactable_id, :use_billing])
      end
    end
  end

  property :_destroy, virtual: true

  # @!attribute quantity
  #   @return [Integer] quantity of ordered items
  property :quantity, default: 1

  # @!attribute transactable_pricing_id
  #   @return [Integer] numeric identifier for the associated pricing object
  #     defining pricing rules
  property :transactable_pricing_id

  # @!attribute transactable_id
  #   @return [Integer] numeric identifier for the associated purchased/reserved
  #     transactable object
  property :transactable_id

  # @!attribute [r] minimum_booking_minutes
  #   @return [Integer] minimum booking minutes for the reservation
  property :minimum_booking_minutes, readonly: true

  # @!attribute periods
  #   @return [Array<ReservationPeriodForm>] array of {ReservationPeriodForm} defining
  #     reserved dates and times for this reservation

  def validate!(*args)
    t = Transactable.find_by(id: @fields['transactable_id'])
    model.creator_id = t.creator_id
    model.company_id = t.company_id
    self.minimum_booking_minutes = t.time_based_booking&.minimum_booking_minutes
    model.minimum_booking_minutes = t.time_based_booking&.minimum_booking_minutes
    super
  end

  def save!
    super
    # FIXME: for now to be able to update reservation. Big refactor required
    # idea - probably skip building line items entirely at this level, and move it
    # to CheckoutForm.
    raise "Reservation was not saved: #{model.errors.full_messages.join(', ')}" if model.changed?
    model.line_items.destroy_all
    model.reload
    model.build_first_line_item
    model.save!
  end
end
