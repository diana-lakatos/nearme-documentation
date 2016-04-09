FactoryGirl.define do
  factory :additional_charge do
    name 'Something cool'
    amount 10.23
    currency 'USD'
    commission_receiver 'mpo'
    status 'mandatory'

    factory :host_additional_charge_type do
      commission_receiver 'host'
    end

  end
end

