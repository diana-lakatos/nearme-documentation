When /^I fill in valid product details$/ do
  add_new_shipping_method
  fill_in 'boarding_form_company_attributes_name', with: 'Socks Store'
  fill_in 'boarding_form_company_attributes_company_address_attributes_address', with: 'usa'
  fill_in 'boarding_form_product_form_name', with: 'Nice Sock'
  fill_in_ckeditor 'boarding_form_product_form_description', with: 'Sock description'
  fill_in 'boarding_form_product_form_price', with: '100'
  fill_in 'boarding_form_product_form_quantity', with: '100'
  page.should have_css('.shipping_method_list input')
  first('.shipping_method_list input').click
  attach_file_via_uploader
end

When /^I partially fill in product details$/ do
  attach_file_via_uploader
  fill_in 'boarding_form_product_form_name', with: 'Nice Sock'
  fill_in_ckeditor 'boarding_form_product_form_description', with: 'Sock description'
  fill_in 'boarding_form_product_form_price', with: '100'
  fill_in 'boarding_form_product_form_quantity', with: '100'
end
