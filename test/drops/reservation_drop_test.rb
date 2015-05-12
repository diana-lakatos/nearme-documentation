require 'test_helper'

class ReservationDropTest < ActiveSupport::TestCase

  setup do
    @reservation = create(:reservation)
  end

  context '#transactable_type' do
    should 'return transactable_type' do
      transactable_type = @reservation.listing.transactable_type
      assert_equal transactable_type, @reservation.to_liquid.transactable_type
    end

    should 'return transcatable type even if listing was deleted' do
      transactable_type = @reservation.listing.transactable_type
      @reservation.listing.destroy
      @reservation.reload
      assert_equal transactable_type, @reservation.to_liquid.transactable_type
    end
  end

end
