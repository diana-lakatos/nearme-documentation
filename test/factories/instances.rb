FactoryGirl.define do

  factory :instance do
    name 'DesksNearMe'
    association :theme
    service_fee_percent '10.00'

    after(:build) do |instance|
      instance.domains << FactoryGirl.create(:domain) if instance.domains.empty?
      instance.theme = FactoryGirl.create(:theme) unless instance.theme
    end

    after(:create) do |instance|
      instance.domains << FactoryGirl.create(:domain) if instance.domains.empty?
      instance.theme = FactoryGirl.create(:theme) unless instance.theme
      instance.save!
    end
  end
end
