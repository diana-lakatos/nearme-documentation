Given /^a listing in (.*) exists$/ do |city|
  instance_variable_set "@listing_in_#{city.downcase.gsub(' ', '_')}",
    FactoryGirl.create("listing_in_#{city.downcase.gsub(' ', '_')}")
end

When /^I create a listing for that location with a price of \$(\d+)\.(\d+)$/ do |dollars, cents|
  visit new_listing_path
  select model!("location").name, from: "Location"
  fill_in "Name", with: "Awesome Listing"
  fill_in "Description", with: "Nulla rutrum neque eu enim eleifend bibendum."
  fill_in "Quantity", with: "2"
  choose "listing_confirm_reservations_true"
  fill_in "Price", with: "#{dollars}.#{cents}"
  click_link_or_button("Create Listing")
  @listing = Listing.find_by_name("Awesome Listing")
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
  page.should have_content(listing.address)
  page.should have_content(listing.name)
  page.should have_content(listing.description.strip)
  page.should have_content(listing.url)
end

Then /^the listing price is shown as (.*)$/ do |amount|
  visit listing_path(listing)
  page.should have_content(amount)
  visit listings_path
  page.should have_content(amount)
end
