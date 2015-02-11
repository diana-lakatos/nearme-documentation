Given /^I am adding new product$/ do
  visit new_dashboard_product_path
end

Given /^A shipping profile exists$/ do
  create_first_shipping_profile
end

And /^I fill products form with valid details$/  do
  fill_product_form
end

And /^I submit the product form$/  do
  page.execute_script("$('form#product_form').submit()")
end

Then /^Product with my details should be created$/  do
  product = Spree::Product.last
  assert_product_data(product)
end
