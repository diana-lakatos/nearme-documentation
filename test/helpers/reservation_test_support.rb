# Helper methods for dealing with reservations in tests
module ReservationTestSupport
  # Prepares a company and initializes some confirmed, charged reservations.
  def prepare_company_with_charged_reservations(options = {})
    options.reverse_merge!(reservation_count: 1)

    transactable = FactoryGirl.create(:transactable)
    transactable.action_type.transactable_type_action_type.update(
      service_fee_guest_percent: 0,
      service_fee_host_percent: 0
    )
    transactable.action_type.day_pricings.first.update(price_cents: 4500)

    prepare_charged_reservations_for_transactable(transactable, options[:reservation_count])
    transactable.company
  end

  # Prepares some charged reservations for a transactable
  def prepare_charged_reservations_for_transactable(transactable, count = 1, _options = {})
    user = FactoryGirl.create(:user)
    payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
    payment_method = payment_gateway.payment_methods.credit_card.first
    stub_active_merchant_interaction

    date = Time.zone.now.advance(weeks: 1).beginning_of_week.to_date
    reservations = []
    count.times do |_i|
      reservation = FactoryGirl.create(:confirmed_reservation, transactable: transactable, company: transactable.company, currency: transactable.currency)
      reservation.payment.destroy
      reservation.payment_attributes = { state: 'paid', payment_method: payment_method, credit_card_attributes: FactoryGirl.attributes_for(:credit_card_attributes) }
      reservation.save
      reservations << reservation
    end
    reservations
  end
end
