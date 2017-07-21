# frozen_string_literal: true
class OrderForm < BaseForm
  RESERVATIONS_POPULATOR = lambda do |collection:, fragment:, index:, as:, **_args|
    item = reservations.find { |c| c.id.to_s == fragment['id'].to_s && fragment['id'].present? }
    if fragment['_destroy'] == '1'
      reservations.delete(item)
      return skip!
    end
    if item
      item
    else
      # if this is new item, we want to remove all persisted
      # i.e. I make a booking for listing A, but I do not pay
      # instead I go to make a booking for B -> this means
      # I resigned from A
      reservations.select(&:persisted?).each { |i| reservations.delete(i) }
      reservations.append(build_reservation_object)
    end
  end.freeze

  class << self
    def decorate(configuration)
      Class.new(self) do
        validate :validate_all_dates_available if configuration.delete(:validate_all_dates_available)

        @reservation_type = configuration.delete(:reservation_type)
        if (reservations_configuration = configuration.delete(:reservations)).present?
          add_validation(:reservations, reservations_configuration)
          collection :reservations, form: ReservationForm.decorate(reservations_configuration),
                                    populator: RESERVATIONS_POPULATOR,
                                    prepopulator: ->(_options) { reservations << build_reservation_object if reservations.size.zero? }
        end
        if (payment_subscription_configuration = configuration.delete(:payment_subscription)).present?
          add_validation(:payment_subscription, payment_subscription_configuration)
          property :payment_subscription, form: PaymentSubscriptionForm.decorate(payment_subscription_configuration),
                                          populate_if_empty: ->(fragment:, **) { model.build_payment_subscription },
                                          prepopulator: ->(_options) { self.payment_subscription ||= model.build_payment_subscription }
        end

        if (order_items_configuration = configuration.delete(:order_items)).present?
          add_validation(:order_items, order_items_configuration)
          collection :order_items, form: OrderItemForm.decorate(order_items_configuration),
                                   populate_if_empty: ->(fragment:, **) { model.order_items.new },
                                   prepopulator: ->(_options) { order_items << model.order_items.new if order_items.empty? }
        end

        if (transactable_configuration = configuration.delete(:transactable)).present?
          add_validation(:transactable, transactable_configuration)
          property :transactable, form: TransactableForm.decorate(transactable_configuration),
                                  populate_if_empty: ->(fragment:, **) { model.build_transactable },
                                  prepopulator: ->(_options) { self.transactable ||= model.build_transactable }
        end

        inject_custom_attributes(configuration)
        inject_dynamic_fields(configuration, whitelisted: [:state_event, :reservation_type_id, :lister_confirm, :with_charge, :schedule_expiry])
      end
    end
  end

  def validate_all_dates_available
    OverbookingValidator.new(model, self).validate
  end

  # @!attribute reservations
  #   @return [Array<ReservationForm>] reservation forms for actual reservations associated with this form
  # @!attribute order_items
  #   @return [Array<OrderItemForm>] array of {OrderItemForm} encapsulating the order items for this order
  # @!attribute payment_subscription
  #   @return [PaymentSubscriptionForm] {PaymentSubscriptionForm} encapsulating the PaymentSubscription
  #     for this order

  def build_reservation_object
    rt = self.class.instance_variable_get(:'@reservation_type')
    model.real_model.reservations.build(
      reservation_type: rt,
      owner: model.real_model.user,
      user: model.real_model.user,
      settings: rt.settings
    )
  end
end
