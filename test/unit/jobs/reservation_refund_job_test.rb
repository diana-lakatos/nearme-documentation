require 'test_helper'

class ReservationRefundJobTest < ActiveSupport::TestCase

  should 'run the right method' do
    @stub = stub()
    @stub.expects(:attempt_payment_refund).with(2)
    Reservation.expects(:find_by_id).with(1).returns(@stub)
    ReservationRefundJob.perform(1, 2)
  end

end
