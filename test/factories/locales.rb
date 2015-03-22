FactoryGirl.define do
  factory :locale do
    code 'en'

    factory :default_locale do
      primary true
    end
  end
end
