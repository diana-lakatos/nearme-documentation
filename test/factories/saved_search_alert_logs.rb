FactoryGirl.define do
  factory :saved_search_alert_log do
    saved_search
    results_count { rand(1000) }
  end
end
