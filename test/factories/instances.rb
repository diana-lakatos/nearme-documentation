FactoryGirl.define do

  factory :instance do
    sequence(:name) {|n| Instance.default_instance ? "desks near me #{n}" : 'DesksNearMe'}
    default_instance false
    bookable_noun 'Desk'
    lessor 'host'
    lessee 'guest'
    service_fee_guest_percent '10.00'

    after(:create) do |instance|
      instance.theme = FactoryGirl.create(:theme, :skip_compilation => true) unless instance.theme
    end

    factory :default_instance do
      default_instance true
    end
  end

end
