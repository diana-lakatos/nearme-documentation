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
  assert page.should have_css("div.result-item", count: 3)
  assert page.should have_css("div.result-item[data-product-id]", count: 1)
end

When /^I add buy sell product to cart$/ do
  find(:css, 'div.result-item a.item').click
  find(:css, '.add_to_cart').click
end

Then /^The product should be included in my cart$/ do
  assert page.should have_css("div.item-description")
  @order = @user.orders.first
  assert @order.present?
  assert_equal 1, @order.line_items.count
  @line_item = @order.line_items.first
  assert_equal 1, @line_item.quantity
  assert page.body.should have_content(@product.name)
end

When /^I begin Checkout process$/ do
  find('.checkout a').click
end

When /^I fill in shippment details$/ do
  fill_in 'order_bill_address_attributes_firstname', with: 'John'
  fill_in 'order_bill_address_attributes_lastname', with: 'Doe'
  fill_in 'order_bill_address_attributes_address1', with: 'Wonderland 1'
  fill_in 'order_bill_address_attributes_city', with: 'San Francisco'
  select 'United States', from: 'order_bill_address_attributes_country_id'
  page.should have_css('#order_bill_address_attributes_state_id option')
  select 'California', from: 'order_bill_address_attributes_state_id'
  fill_in 'order_bill_address_attributes_zipcode', with: '94102'

  fill_in 'order_ship_address_attributes_firstname', with: 'John'
  fill_in 'order_ship_address_attributes_lastname', with: 'Doe'
  fill_in 'order_ship_address_attributes_address1', with: 'Wonderland 1'
  fill_in 'order_ship_address_attributes_city', with: 'San Francisco'
  select 'United States', from: 'order_ship_address_attributes_country_id'
  page.should have_css('#order_ship_address_attributes_state_id option')
  select 'California', from: 'order_ship_address_attributes_state_id'
  fill_in 'order_ship_address_attributes_zipcode', with: '94102'

  click_button 'Next'
end

And /^I choose shipping method$/ do
  assert page.should have_css("div.shipping-options")
  assert page.should have_css("div.radio-select", count: 1)
  assert page.should have_css("div.radio-select input:checked", count: 1)

  @shipping_category.shipping_methods.each do |sm|
    assert page.body.should have_content(sm.name)
  end

  click_button 'Next'
end

Then /^I should see order summary page$/ do
  assert page.body.should have_content("Order Summary")
  @order = @user.orders.first
  total = @order.item_total.to_f + @order.shipment_total.to_f + @order.additional_tax_total.to_f + @order.service_fee_amount_guest.to_f
  assert_equal ("$%.2f" % total), page.all(:css, ".payment-totals .total").last.text
end

When /^I fill billing data$/ do
  fill_in 'order_card_holder_first_name', with: 'John'
  fill_in 'order_card_holder_last_name', with: 'Doe'
  fill_in 'order_card_number', with: '4111111111111111'
  fill_in 'order_card_expires', with: 1.years.from_now.strftime("%m/%Y")
  fill_in 'order_card_code', with: '111'
  click_button 'Next'
  save_and_open_page
  binding.pry
end

And /^I should see order placed confirmation$/ do
  assert page.body.should have_content(I18n.t('buy_sell_market.checkout.notices.order_placed'))
end

Then /^The product should not be included in my cart$/ do
  assert page.body.should have_content(I18n.t('buy_sell_market.checkout.notices.order_placed'))
end


