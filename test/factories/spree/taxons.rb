FactoryGirl.define do
  factory :taxons, class: Spree::Taxon do
    name { Faker::Lorem.word }
  end
end
