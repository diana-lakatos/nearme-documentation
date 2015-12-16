FactoryGirl.define do
  factory :additional_charge_type do
    name 'Insurance'
    amount 10
    currency 'USD'
    commission_receiver 'mpo'
    status 'mandatory'
    additional_charge_type_target { Instance.first.signature }

    factory :host_additional_charge_type do
      commission_receiver 'host'
    end

    factory :transactable_additional_charge_type do
      additional_charge_type_target {  [(Transactable.last || FactoryGirl.create(:transactable)).id, "Transactable"].join(",") }
      commission_receiver 'host'
    end
  end
end
