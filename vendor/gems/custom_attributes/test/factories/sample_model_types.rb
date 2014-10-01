FactoryGirl.define do
  factory :sample_model_type do
    sequence(:name) { |n| "Sampel Model Type #{n}" }
  end
end
