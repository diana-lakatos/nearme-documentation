Given /^a listing in (.*) exists$/ do |city|
  instance_variable_set "@listing_in_#{city.downcase.gsub(' ', '_')}",
    FactoryGirl.create("listing_in_#{city.downcase.gsub(' ', '_')}")
end

Then /^I (do not )?see a search result for the (.*) listing$/ do |negative, city|
  listing = instance_variable_get("@listing_in_#{city.downcase.gsub(' ', '_')}")
  if negative
    page.should have_no_content(listing.name)
  else
    page.should have_content(listing.name)
  end
end

Then /^I see the listing details$/ do
  listing = model!("listing")
  page.should have_content(listing.address)
  page.should have_content(listing.name)
  page.should have_content(listing.description)
  page.should have_content(listing.url)
end
