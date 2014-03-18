require 'test_helper'

class ReservationRefundJobTest < ActiveSupport::TestCase

  should 'run the right method' do
    reservation = FactoryGirl.create(:reservation)
    reservation.expects(:attempt_payment_refund).with(2)
    Reservation.expects(:find_by_id).with(1).returns(reservation)
    ReservationRefundJob.perform(1, 2)
  end

end
