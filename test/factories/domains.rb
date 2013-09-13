FactoryGirl.define do
  factory :domain do
    sequence(:name) {|n| Domain.exists?(name: Domain::DEFAULT_DOMAIN_NAME) ? "desksnear#{n}.me" : Domain::DEFAULT_DOMAIN_NAME}
    target_type "Instance"
  end
end
