FactoryGirl.define do

  factory :reservation_type do
    sequence(:name) { |n| "Reservation Type #{n}" }

    after(:build) do |reservation_type|
      tt = TransactableType.last || FactoryGirl.create(:transactable_type, reservation_type: reservation_type)
      reservation_type.transactable_types << tt
    end

    after(:create) do |reservation_type|
      Utils::FormComponentsCreator.new(reservation_type).create!
    end
  end

end
