Given /^a listing in (.*)$/ do |city|
  FactoryGirl.create("listing_in_#{city.downcase.gsub(' ', '_')}".to_sym)
end
