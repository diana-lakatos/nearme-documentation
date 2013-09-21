FactoryGirl.define do

  factory :instance do
    # please note that default factory should be loaded via fixtures/instances.yml !
    sequence(:name) {|n| Instance.default_instance ? "desks near me #{n}" : 'DesksNearMe'}
    bookable_noun 'Desk'
    service_fee_percent '10.00'

    after(:create) do |instance|
      instance.theme = Theme.create(:skip_compilation => true) unless instance.theme
    end
  end

end
