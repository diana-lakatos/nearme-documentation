require 'test_helper'

class AdditionalChargeTest < ActiveSupport::TestCase
  should belong_to(:instance)
  should belong_to(:additional_charge_type)
  should belong_to(:target)

  should 'populate all the required data from' do
    act = FactoryGirl.create(:additional_charge_type)
    ac = AdditionalCharge.create(additional_charge_type_id: act.id)
    assert_equal ac.name, act.name
    assert_equal ac.amount_cents, act.amount_cents
    assert_equal ac.commission_receiver, act.commission_receiver
  end
end
