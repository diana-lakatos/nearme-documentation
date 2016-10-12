FactoryGirl.define do
  factory :location do
    email 'psherman@smilehouse.com'
    description 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    availability_template_id { (AvailabilityTemplate.first || FactoryGirl.create(:availability_template)).id }
    association(:location_type, factory: :location_type)
    company
    association :location_address, factory: :address
    time_zone 'UTC'

    factory :always_open_location do
      availability_template_id { (AvailabilityTemplate.find_by(name: '24/7') || FactoryGirl.create(:availability_template_always_open)).id }
    end

    factory :location_in_auckland do
      association :location_address, factory: :address_in_auckland
      association(:company, factory: :company_in_auckland)
    end

    factory :location_in_adelaide do
      association :location_address, factory: :address_in_adelaide
      association(:company, factory: :company_in_adelaide)
    end

    factory :location_in_cleveland do
      association :location_address, factory: :address_in_cleveland
      association(:company, factory: :company_in_cleveland)
    end

    factory :location_in_san_francisco do
      association :location_address, factory: :address_in_san_francisco
      association(:company, factory: :company_in_san_francisco)
    end

    factory :location_in_wellington do
      association :location_address, factory: :address_in_wellington
      association(:company, factory: :company_in_wellington)
    end

    factory :location_ursynowska_address_components do
      association :location_address, factory: :address_ursynowska_address_components
    end

    factory :location_rydygiera do
      email 'example@empty.com'
      description 'desc'
      association :location_address, factory: :address_rydygiera
    end

    factory :location_czestochowa do
      description 'desc2'
      email 'maciej.krajowski@gmail.com'

      association :location_address, factory: :address_czestochowa
    end

    factory :location_warsaw_address_components do
      association :location_address, factory: :address_warsaw_address_components
    end

    factory :location_san_francisco_address_components do
      association :location_address, factory: :address_san_francisco_address_components
    end

    factory :location_vaughan_address_components do
      association :location_address, factory: :address_vaughan_address_components
    end

    factory :location_with_white_label_company do
      association :location_address, factory: :address_ursynowska_address_components
      association(:company, factory: :white_label_company)
    end
  end
end
