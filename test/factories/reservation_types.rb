FactoryGirl.define do

  factory :reservation_type do
    sequence(:name) { |n| "Reservation Type #{n}" }

    after(:create) do |reservation_type|
      Utils::FormComponentsCreator.new(reservation_type).create!
    end
  end


end
