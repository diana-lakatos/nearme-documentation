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
    Billing::Gateway::Processor::Incoming::Stripe.any_instance.stubs(:charge).returns(true)
    listing.instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)

    date = Time.zone.now.advance(:weeks => 1).beginning_of_week.to_date
    reservations = []
    count.times do |i|
      reservations << FactoryGirl.create(:reservation_with_credit_card,
        :listing => listing,
        :date => date + i
      )
    end
    reservations.each(&:confirm)
  end

end

