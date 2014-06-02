require 'vcr_setup'

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
  def prepare_charged_reservations_for_listing(listing, count = 1)
    listing.instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)
    ipg = FactoryGirl.create(:stripe_instance_payment_gateway)
    listing.instance.instance_payment_gateways << ipg
    
    country_ipg = FactoryGirl.create(
      :country_instance_payment_gateway, 
      country_alpha2_code: "US", 
      instance_payment_gateway_id: ipg.id
    )

    listing.instance.country_instance_payment_gateways << country_ipg
    

    date = Time.zone.now.advance(:weeks => 1).beginning_of_week.to_date
    reservations = []
    count.times do |i|
      reservation = FactoryGirl.create(:reservation_with_credit_card,
        :listing => listing,
        :date => date + i
      )
      
      billing_gateway = Billing::Gateway::Incoming.new(reservation.owner, listing.instance, reservation.currency)
      VCR.use_cassette("reservation_support_authorize_#{i}") do
        response = billing_gateway.authorize(reservation.total_amount_cents, credit_card)
        mode = reservation.instance.test_mode? ? "test" : "live"
        reservation.create_billing_authorization(token: response[:token], payment_gateway_class: response[:payment_gateway_class], payment_gateway_mode: mode)
        reservation.save
        reservations << reservation
      end
    end
  
    reservations.each_with_index do |reservation, i|
      VCR.use_cassette("reservation_support_capture_#{i}") do
        reservation.confirm
      end
    end
  end

  def credit_card
    credit_card = ActiveMerchant::Billing::CreditCard.new(
      first_name: "Name",
      last_name: "Last Name",
      number: "4242424242424242",
      month: "05",
      year: "2020",
      verification_value: "411"
    )
  end

end

