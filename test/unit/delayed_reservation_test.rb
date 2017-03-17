# frozen_string_literal: true
require 'test_helper'

# PLEASE NOTE: # This test is now divided into context based on reservation state:
# If you want to add new test please do so in correct section unless it does not fit to any

class ReservationTest < ActiveSupport::TestCase
  include ReservationsHelper
  context 'State test: ' do
    context 'unconfirmed reservation' do
      setup do
        @reservation = FactoryGirl.create(:unconfirmed_delayed_reservation)
      end

      should 'move to archived when paid' do
        travel_to Time.zone.now do
          OrderMarkAsArchivedJob.expects(:perform_later).at_least(1)
          @reservation.payment.update_attribute(:state, 'paid')
          @reservation.confirm
        end
      end

      should 'not move to archived when not paid' do
        travel_to Time.zone.now do
          OrderMarkAsArchivedJob.expects(:perform_later).never
          @reservation.confirm
        end
      end

      should 'recalucalte host fee on rebuild' do
        host_fee = @reservation.host_fee_line_items.last
        @reservation.rebuild_first_line_item
        new_host_fee = @reservation.host_fee_line_items.last
        assert host_fee.deleted?
        assert_equal host_fee.total_price, new_host_fee.total_price
        assert_not_equal host_fee.id, new_host_fee.id
      end
    end
  end
end
