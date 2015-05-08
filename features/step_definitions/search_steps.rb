When /^I search for "([^"]*)"$/ do |text|
  search_for(text)
end

When /^I search for located "([^"]*)"$/ do |text|
  SearchController.any_instance.stubs(:params).returns(ActionController::Parameters.new({:lat => 1, :lng => 1, :loc => text}))
  search_for(text)
end

Given /^Auckland listing has fixed_price: (.*)$/ do |fixed_price|
  listing = Transactable.last
  listing.min_fixed_price_cents = 0
  listing.max_fixed_price_cents = fixed_price.to_i * 100 + 1
  listing.fixed_price_cents = fixed_price.to_i * 100
  listing.action_free_booking = true if !listing.has_price?
  listing.save(validate: false)
end

When /^I search for "([^"]*)" with prices (\d+) (\d+)$/ do |query, min, max|
  visit search_path(:q => query, "price[min]" => min, "price[max]" => max, :lgpricing => "fixed")
end

When /^I search for product "([^"]*)"$/ do |text|
  search_for_product(text)
end

When /^I performed search for "([^"]*)"$/ do |query|
  visit search_path(:q => query)
end

When /^I make another search for "([^"]*)"$/ do |query|
  visit root_path
  search_for(query)
end

When /^I leave the page and hit back$/ do
  visit root_path
  page.evaluate_script('window.history.back()')
end

Then /^I should see a notification for my subscription$/ do
  page.find('.alert').should have_content("You will be notified when this location will be added.")
end

Then /^I (do not )?see a search results for the ([^\$].*)$/ do |negative, product|
  product = model!(product)
  if negative
    page.should have_no_selector('.result-item[data-product-id="' + product.id.to_s + '"]')
  else
    page.should have_selector('.result-item[data-product-id="' + product.id.to_s + '"]')
  end
end
