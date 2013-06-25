require 'test_helper'

class ReservationMailerTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @reservation = FactoryGirl.create(:reservation)
  end

  test "correct path and auth token in dashboard link" do
    mail = ReservationMailer.notify_host_with_confirmation(@reservation)
    assert mail.html_part.body.include?( manage_guests_dashboard_path(:token => @reservation.listing.creator.authentication_token) )    
  end

end
