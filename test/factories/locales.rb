FactoryGirl.define do
  factory :locale do
    code 'en'

    factory :primary_locale do
      primary true
    end
  end
end
