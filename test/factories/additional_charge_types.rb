FactoryGirl.define do
  factory :additional_charge_type do
    name 'Insurance'
    amount 10
    currency 'USD'
    commission_for 'mpo'
    status 'mandatory'
  end
end
