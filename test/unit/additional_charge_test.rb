require 'test_helper'

class AdditionalChargeTest < ActiveSupport::TestCase

  should belong_to(:instance)
  should belong_to(:additional_charge_type)
  should belong_to(:target)

  should validate_presence_of :additional_charge_type_id

  should 'populate all the required data from' do
    act = FactoryGirl.create(:additional_charge_type)
    ac = AdditionalCharge.create(additional_charge_type_id: act.id)
    assert_equal ac.name, act.name
    assert_equal ac.amount_cents, act.amount_cents
    assert_equal ac.currency, act.currency
    assert_equal ac.commission_for, act.commission_for
  end
end
