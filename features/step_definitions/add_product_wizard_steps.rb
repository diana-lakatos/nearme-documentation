Given(/^current instance with integrated shipping$/) do
  Instance.any_instance.stubs(:shippo_enabled?).returns(true)
end

When /^I fill in valid product details$/ do
  add_new_shipping_method
  fill_product_fields
end

When /^I partially fill in product details$/ do
  attach_file_via_uploader
  fill_in 'boarding_form_product_form_name', with: 'Nice Sock'
  fill_in_ckeditor 'boarding_form_product_form_description', with: 'Sock description'
  fill_in 'boarding_form_product_form_price', with: '100'
  fill_in 'boarding_form_product_form_quantity', with: '100'
end

When /^I fill in valid product details with integrated shipping$/ do
  add_new_integrated_shipping_method
  fill_product_fields
end
