# Helper methods for dealing with reservations in tests
module ReservationTestSupport
  # Prepares a company and initializes some confirmed, charged reservations.
  def prepare_company_with_charged_reservations(options = {})
    options.reverse_merge!(:reservation_count => 1, :listing => { :daily_price => 50 })

    listing = FactoryGirl.create(:transactable, options[:listing])
    prepare_charged_reservations_for_listing(listing, options[:reservation_count])
    listing.company
  end

  # Prepares some charged reservations for a listing
  def prepare_charged_reservations_for_listing(listing, count = 1, options = {})
    stub_billing_gateway(listing.instance)
    stub_active_merchant_interaction

    date = Time.zone.now.advance(:weeks => 1).beginning_of_week.to_date
    reservations = []
    count.times do |i|
      reservation = FactoryGirl.create(:reservation_with_credit_card,
        :listing => listing,
        :date => date + i
      )
      if options.has_key?("reservation_#{i}".to_sym)
        options["reservation_#{i}".to_sym].each do |key, value|
          reservation.update_attribute(key, value)
        end
      end

      billing_gateway = Billing::Gateway::Incoming.new(reservation.owner, listing.instance, reservation.currency, 'US')
      response = billing_gateway.authorize(reservation.total_amount_cents, credit_card)
      reservation.create_billing_authorization(token: response[:token], payment_gateway_class: response[:payment_gateway_class], payment_gateway_mode: :test)
      reservation.save
      reservations << reservation
    end

    reservations.each(&:confirm)
  end

  def credit_card
    ActiveMerchant::Billing::CreditCard.new(
      first_name: "Name",
      last_name: "Last Name",
      number: "4242424242424241",
      month: "05",
      year: "2020",
      verification_value: "411"
    )
  end

end

