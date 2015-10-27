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
    user = FactoryGirl.create(:user)
    payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
    payment_method = payment_gateway.payment_methods.first
    stub_active_merchant_interaction

    date = Time.zone.now.advance(:weeks => 1).beginning_of_week.to_date
    reservations = []
    count.times do |i|
      reservation_request_attributes = FactoryGirl.attributes_for(:reservation_request, payment_method: payment_method)
      reservation_request_attributes.merge!({ dates:[(date + i).to_s(:db)] })

      reservation_request = ReservationRequest.new(listing, user, PlatformContext.current, reservation_request_attributes )
      reservation_request.process

      if options.has_key?("reservation_#{i}".to_sym)
        reservation_request.reservation.update_attributes(options["reservation_#{i}".to_sym])
      end

      reservations << reservation_request.reservation
    end

    reservations.each(&:confirm)
  end
end
