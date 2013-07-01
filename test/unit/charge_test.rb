require 'test_helper'

class ChargeTest < ActiveSupport::TestCase

  should belong_to(:user)
  should belong_to(:reference)

  context 'last x days' do

    setup do
      5.times do |i|
        3.times do |j|
          FactoryGirl.create(:charge, :created_at => (Date.today - i.days))
        end
      end
    end

    should 'be able to scope to x days correctly' do
      assert_equal 12, Charge.last_x_days(4).count
    end
    
    should 'be able to scope to x days correctly even if last charge was before end date' do
      assert_equal 15, Charge.last_x_days(8).count
    end

  end

end
