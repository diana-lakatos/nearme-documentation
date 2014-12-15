Given /^Current marketplace is buy_sell$/ do
  TransactableType.destroy_all
  @instance = PlatformContext.current.instance
  FactoryGirl.create(:transactable_type_buy_sell)
  Utils::SpreeDefaultsLoader.new(@instance).load!
  @instance.update_attribute(:service_fee_host_percent, 10)
  @instance.update_attribute(:service_fee_guest_percent, 15)
  @instance.update_attribute(:payment_transfers_frequency, 'daily')
end

Given /^A buy sell product exist in current marketplace$/ do
  @user = User.first
  @user.update_column(:country_name, 'United States')
  @shipping_category = Spree::ShippingCategory.first
  @stock_location = Spree::StockLocation.first
  @product = FactoryGirl.create(:base_product, shipping_category: @shipping_category)
  @shipping_category.update_attribute(:company_id, @product.company_id)
  @stock_location.update_attribute(:company_id, @product.company_id)
  @shipping_category.shipping_methods.each do |sm|
    sm.update_attributes(company_id: @product.company_id, name: 'Custom Shipping')
  end
  @stock_item = @stock_location.stock_items.create(variant_id: @product.id)
  @stock_item.update_attribute(:count_on_hand, 1)
  FactoryGirl.create(:base_product, name: 'Some weird stuff!')
end


When /^I search for buy sell "([^"]*)"$/ do |product_name|
  visit search_path(loc: product_name)
end

Then /^I should see relevant buy sell products$/ do
  assert page.body.should have_content(@product.name)
  assert page.should have_css("article.product", count: 1)
end

When /^I add buy sell product to cart$/ do
  find(:css, 'article.product .photo a').click
  find(:css, '.add_to_cart').click
end

Then /^The product should be included in my cart$/ do
  @order = @user.orders.first
  assert @order.present?
  assert_equal 1, @order.line_items.count
  @line_item = @order.line_items.first
  assert_equal 1, @line_item.quantity
  assert page.body.should have_content(@product.name)
end

When /^I begin Checkout process$/ do
  click_link 'Checkout'
end

When /^I fill in shippment details$/ do
  fill_in 'order_bill_address_attributes_address1', with: 'Wonderland 1'
  fill_in 'order_bill_address_attributes_city', with: 'San Francisco'
  select 'United States', from: 'order_bill_address_attributes_country_id'
  page.should have_css('#order_bill_address_attributes_state_id option')
  select 'California', from: 'order_bill_address_attributes_state_id'
  fill_in 'order_bill_address_attributes_zipcode', with: '94102'
  fill_in 'order_bill_address_attributes_lastname', with: 'Doe'
  check 'order_use_billing'
  sleep(1)
  save_and_open_page
  click_button 'Next step'
end

When /^I choose shipping method$/ do
  save_and_open_page
  select 'Custom Shipping', from: 'order_shipments_attributes_0_selected_shipping_rate_id'
end
